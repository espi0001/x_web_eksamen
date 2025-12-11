const burger = document.querySelector(".burger");
const nav = document.querySelector("nav");

// ##############################
async function server(url, method, data_source_selector, function_after_fetch) {
  let conn = null;

  // Handle POST method and send form data
  if (method.toUpperCase() == "POST") {
    const data_source = document.querySelector(data_source_selector);
    conn = await fetch(url, {
      method: method,
      body: new FormData(data_source),
    });
  }

  // Read server response as text
  const data_from_server = await conn.text();

  if (!conn) {
    console.log("error connecting to the server");
  }

  // Call the callback function dynamically
  window[function_after_fetch](data_from_server);
}

// ##############################
// function get_search_results(url, method, data_source_selector, function_after_fetch) {
//   const txt_search_for = document.querySelector("#txt_search_for");
//   if (txt_search_for.value == "") {
//     console.log("empty search");
//     document.querySelector("#search_results").innerHTML = "";
//     document.querySelector("#search_results").classList.add("d-none");
//     return false;
//   }
//   server(url, method, data_source_selector, function_after_fetch);
// }
// // ##############################
// function parse_search_results(data_from_server) {
//   data_from_server = JSON.parse(data_from_server);

//   let html_output = "";

//   if (data_from_server.users && data_from_server.users.length) {
//     data_from_server.users.forEach((user) => {
//       let user_avatar_path = user.user_avatar_path || "unknown.jpg";

//       html_output += `
//     <div class="d-flex a-items-center mb-2">
//       <img src="/${user_avatar_path}" class="w-8 h-8 rounded-full">
//       <div class="w-full ml-2">
//         <p>${user.user_name}
//           <span class="text-c-gray:+20 text-70">@${user.user_username}</span>
//         </p>
//       </div>
//          ${user.followed_by_user ? user.unfollow_button_html : user.follow_button_html}
//     </div>
//   `;
//     });
//   }

//   if (data_from_server.posts && data_from_server.posts.length) {
//     data_from_server.posts.forEach((post) => {
//       html_output += `
//             <div class="search_post d-flex flex-col mb-2 p-2 bg-c-white">
//                 <p class="text-c-gray text-sm">${post.post_message}</p>
//             </div>`;
//     });
//   }

//   if (!html_output) {
//     html_output = "<p>No results found.</p>";
//   }

//   const resultsContainer = document.querySelector("#search_results");
//   resultsContainer.innerHTML = html_output;
//   resultsContainer.classList.remove("d-none");
// }

// ##############################
burger.addEventListener("click", () => {
  // toggle nav
  nav.classList.toggle("active");

  // toggle icon
  burger.classList.toggle("open");
});

// ==================== POST MEDIA PREVIEW ====================
// Uses event delegation so the preview works even if the form is replaced dynamically
document.addEventListener("change", function (e) {
  // Only run if the file input for posts was changed
  if (e.target && e.target.id === "post_media_input") {
    const fileInput = e.target;
    const previewArea = document.getElementById("media_preview_area");
    if (!previewArea) return;

    const file = e.target.files[0];
    if (!file) return;

    // Clear previous preview
    previewArea.innerHTML = "";

    const fileURL = URL.createObjectURL(file);
    const fileType = file.type;

    // Create wrapper element for preview
    const wrapper = document.createElement("div");
    wrapper.className = "preview-wrapper";

    // Render image preview
    if (fileType.startsWith("image/")) {
      const img = document.createElement("img");
      img.src = fileURL;
      img.alt = "Preview";
      wrapper.appendChild(img);

      // Render video preview
    } else if (fileType.startsWith("video/")) {
      const video = document.createElement("video");
      video.src = fileURL;
      video.controls = true;
      wrapper.appendChild(video);
    }

    // Add remove button to clear preview
    const removeBtn = document.createElement("button");
    removeBtn.innerHTML = "X";
    removeBtn.className = "remove-preview-btn";
    removeBtn.type = "button";
    removeBtn.title = "Remove";
    removeBtn.onclick = function () {
      previewArea.innerHTML = "";
      fileInput.value = "";
    };

    wrapper.appendChild(removeBtn);
    previewArea.appendChild(wrapper);
  }
});

// Optional: Reset form after successful post
// This listens for form submission and resets after a delay
document.addEventListener("submit", function (e) {
  if (e.target && e.target.classList.contains("create-post-form")) {
    // Wait a bit for mix-replace to complete, then reset
    setTimeout(function () {
      const textarea = e.target.querySelector(".post-form-textarea");
      const fileInput = e.target.querySelector("#post_media_input");
      const previewArea = document.getElementById("media_preview_area");
      if (textarea) textarea.value = "";
      if (fileInput) fileInput.value = "";
      if (previewArea) previewArea.innerHTML = "";
    }, 200);
  }
});

// Profile Tabs - Handles tab-change on the profile page
document.addEventListener("click", function (e) {
  // Check if the clicked element is a tab-btn
  if (e.target.classList.contains("tab-btn")) {
    // Remove 'active' from all tab buttons
    document.querySelectorAll(".tab-btn").forEach((btn) => {
      btn.classList.remove("active");
    });

    // Add 'active' class on the clicked tab button
    e.target.classList.add("active");
  }
});
// ==================== AVATAR PREVIEW ====================
document.addEventListener("change", function (e) {
  // Kun kør hvis det er avatar input der ændres
  if (e.target && e.target.id === "avatar") {
    const fileInput = e.target;
    const avatarImg = document.getElementById("current_avatar");

    if (!avatarImg) return;

    const file = fileInput.files[0];
    if (!file) return;

    // Validering: Skal være et billede
    if (!file.type.startsWith("image/")) {
      alert("Vælg venligst et billedfil");
      fileInput.value = "";
      return;
    }

    // Validering: Max størrelse (1MB)
    const maxSize = 1024 * 1024; // 1MB
    if (file.size > maxSize) {
      alert("Billedet er for stort. Max 1MB");
      fileInput.value = "";
      return;
    }

    // Vis preview med FileReader
    const reader = new FileReader();

    reader.onload = function (event) {
      // Opdater avatar billedet med det nye
      avatarImg.src = event.target.result;
    };

    // Læs filen som data URL
    reader.readAsDataURL(file);
  }
});
