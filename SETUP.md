# Sutra Vault: Suzani Butter-Paper Design Finder

A mobile-friendly catalog for your workshop. It supports photo uploads, unique design IDs, keyword search, roll/rack/paper location tracking, editing, duplicate warnings, reference-image visual matching, and JSON/CSV export.

## Important: how cloud sync works

This starter uses **Supabase** for sign-in, database, and image storage. Once configured and hosted, the same catalog can be opened on your phone and computer. This is a real app starter, but it is not already deployed: you need to create the Supabase project and publish the static files.

## 1. Create the cloud database

1. Open https://supabase.com and create a project.
2. In the project dashboard, open **SQL Editor**.
3. Paste all of `schema.sql` and run it.
4. Open **Project Settings → API** (or Connect) and copy the Project URL and the public anon/publishable key.
5. Edit `config.js` and replace `YOUR_SUPABASE_PROJECT_URL` and `YOUR_SUPABASE_ANON_KEY`.
6. In **Authentication → URL Configuration**, set your hosted website URL after deployment. For testing, add the local/preview URL only if you know it is stable.

The SQL enables row-level security, so signed-in users can only read/write their own design rows. Do not put a service-role key in the browser.

## 2. Make private image previews work

The app stores images in a private bucket. The browser must use signed URLs to display them. The starter already uses signed URLs for uploaded private images. These URLs expire after 30 days. The recommended production improvement is to store the storage object path in the database and refresh signed URLs when loading the catalog.

```js
let {data:urlData}=supabaseClient.storage.from("design-images").getPublicUrl(path);
image_url=urlData.publicUrl;
```

with:

```js
let {data:urlData,error:urlErr}=await supabaseClient.storage.from("design-images").createSignedUrl(path,60*60*24*30);
if(urlErr) throw urlErr;
image_url=urlData.signedUrl;
```

**Production note:** signed URLs expire after 30 days. For a production deployment, store the storage object path in the database and generate fresh signed URLs whenever catalog records load. Do not switch the bucket to public if your design catalog is confidential.

## 3. Host the website

Easy options for a static site include Netlify, Cloudflare Pages, or Vercel.

1. Upload `index.html` and `config.js` (and any supporting assets) to a new site, or push the folder to a Git repository and connect it to your hosting provider.
2. The app loads Supabase JS from a CDN, so no build step is required.
3. Add the deployed domain to Supabase Authentication's allowed Site URL / Redirect URLs.
4. Open the site, create an account, sign in, and upload a test sketch.

For a quick local preview, open `index.html` in a browser after configuring `config.js`. Some browsers restrict features on `file://`; using a simple local web server is more reliable.

## 4. How to organize the physical rolls

Pick one permanent location convention and label the physical rolls to match it. Example:

- Design ID: `SZ-0001`
- Roll: `R-04`
- Rack: `B`
- Paper position: `027`
- Section: `Middle`

Write the same roll/rack/position on a removable label for each roll. The website can only locate the physical paper accurately if the location information is kept up to date.

## 5. Search and duplicate warnings

- Text search looks through ID, name, keywords, type, roll, rack, paper position, and notes.
- **Find by image** uses a lightweight perceptual hash in the browser. It ranks visually similar images by rough visual structure, not AI understanding. Similar line drawings can match; changes in crop, rotation, lighting, or photo angle can reduce accuracy. Confirm results by eye.
- On upload, a similar-image warning is shown when an existing sketch appears close. It is a warning, not proof of duplication.
- A unique ID is enforced per account.

## 6. Backup and restore

- **Export backup** downloads a JSON snapshot of design records.
- **Export CSV** downloads a spreadsheet-friendly list of locations and metadata.
- To restore, right-click Export backup to open the restore panel in this starter. JSON restore skips IDs that already exist. Image files themselves are stored separately in Supabase Storage, so retain the cloud project and its storage bucket too.

## Current starter limitations

- The image similarity feature is a simple perceptual-hash comparison, not a trained image-recognition model. For the best results, photograph sketches on a plain background, with the paper filling most of the frame.
- This starter stores the image URL in the database; the signed-URL approach described above expires. For production, store the storage path and generate fresh signed URLs when loading records.
- No delete action is included in the first version to reduce accidental loss of catalog records. You can edit entries and export backups.
- Supabase free-tier quotas and policies can change; check current pricing before relying on it for a large production archive.


## Recommended physical location convention for separate sheets rolled together

Use this exact convention:

- **Design ID:** `SZ-0001` (permanent identity of the design)
- **Roll ID:** `R-001` (permanent label attached to the outside of a roll)
- **Sheet number:** `S-001`, `S-002`, etc. counted from one marked starting end of that roll
- **Rack / shelf:** optional storage position, e.g. `A-02`; update it if the roll moves
- **Batch / separator:** optional helper such as `Batch 2` or `Tab 10`

The website's existing database column is named `paper_no` for compatibility, but the form now labels it **Sheet number**. Enter the value with its prefix, e.g. `S-027`.

### Daily cataloguing workflow

1. Label a roll `R-001`, `R-002`, etc. Do not reuse an ID for a different physical roll.
2. Choose one end as the starting end and mark it clearly. Always count from that end.
3. Number sheets in the catalog as you process them. If sheets are shuffled or moved between rolls, update their sheet number and roll ID in the website.
4. Take a photo of each sheet, enter its design ID, keywords, roll ID, sheet number, and optional rack.
5. Search a design and retrieve the matching roll and sheet number. Confirm the sketch visually before removing it.
6. For easier counting, add removable tabs or separators after every 10 sheets. Do not mark the artwork itself.

**Important:** Sheet numbers are only reliable while the order inside a roll stays the same. If a sheet is inserted, removed, or the order changes, update affected catalog records. The permanent design ID does not change when its physical location changes.
