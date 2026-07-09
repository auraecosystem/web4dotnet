@Html.TXTextControl().DocumentViewer(settings => {
   settings.DocumentPath = Server.MapPath("~/App_Data/Documents/WhyMicrosoftCloudForISVs.pdf");
   settings.Dock = DocumentViewerSettings.DockStyle.Fill;
   settings.IsSelectionActivated = true;
   settings.ShowThumbnailPane = true;
   settings.DocumentLoadSettings.PDFJS.BasePath = "https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.2.146";
}).Render()
