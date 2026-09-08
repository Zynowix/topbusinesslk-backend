/**
 * ==============================================================================
 * TopBusiness.lk — Google Apps Script for Google Forms / Google Sheets Sync
 * ==============================================================================
 * 
 * Instructions:
 * 1. Open your Google Sheet or Google Form (connected to a Sheet).
 * 2. In Google Sheets, click: Extensions > Apps Script.
 * 3. Replace the code in the editor with this entire script.
 * 4. Fill in your NEXT_PUBLIC_SUPABASE_URL and SUPABASE_ANON_KEY below.
 * 5. Click "Triggers" (clock icon on the left) > Add Trigger:
 *    - Function to run: onFormSubmit
 *    - Event source: From spreadsheet
 *    - Event type: On form submit
 * 6. Save! Every new Google Form submission will automatically sync to TopBusiness.lk
 *    and appear instantly in the Admin Review Queue!
 * ==============================================================================
 */

const SUPABASE_URL = "https://rodoltevqllzmbohitrr.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJvZG9sdGV2cWxsem1ib2hpdHJyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg4MzYxODUsImV4cCI6MjEwNDQxMjE4NX0.3FdY7bRRi4S3MT8wgrAMtPfWgLy1tqRxIwDImUQ-Ex8";

function onFormSubmit(e) {
  try {
    const responses = e ? e.namedValues : null;
    
    // Default column mappings (adjust keys according to your Google Form questions)
    const name = getField(responses, ["Business Name", "Business name", "Name of Business", "Company Name"]);
    const owner = getField(responses, ["Owner Name", "Your Name", "Applicant Name", "Contact Person"]) || "Applicant";
    const category = getField(responses, ["Category", "Business Category", "Industry"]) || "Other";
    const district = getField(responses, ["District", "Location", "City", "Province"]) || "Colombo";
    const phone = getField(responses, ["Phone Number", "Contact Number", "WhatsApp Number", "Phone"]);
    const email = getField(responses, ["Email Address", "Email", "Your Email"]) || "";
    const description = getField(responses, ["Business Description", "Description", "About your business", "Services"]) || "";
    const link = getField(responses, ["Website or Social Link", "Website", "Facebook", "Instagram", "Social Page"]) || "";

    if (!name || !phone) {
      Logger.log("Skipping row: missing required Business Name or Phone number.");
      return;
    }

    const payload = {
      name: name.trim(),
      owner: owner.trim(),
      category: category.trim(),
      district: district.trim(),
      phone: phone.trim(),
      email: email.trim(),
      link: link.trim(),
      description: description.trim(),
      status: "pending"
    };

    const options = {
      method: "post",
      contentType: "application/json",
      headers: {
        "apikey": SUPABASE_ANON_KEY,
        "Authorization": "Bearer " + SUPABASE_ANON_KEY,
        "Prefer": "return=minimal"
      },
      payload: JSON.stringify(payload),
      muteHttpExceptions: true
    };

    const response = UrlFetchApp.fetch(SUPABASE_URL + "/rest/v1/submissions", options);
    Logger.log("Synced to Supabase response code: " + response.getResponseCode());
  } catch (err) {
    Logger.log("Error syncing submission to TopBusiness.lk: " + err.toString());
  }
}

function getField(namedValues, possibleHeaders) {
  if (!namedValues) return "";
  for (let i = 0; i < possibleHeaders.length; i++) {
    const key = possibleHeaders[i];
    if (namedValues[key] && namedValues[key][0]) {
      return namedValues[key][0];
    }
  }
  return "";
}
