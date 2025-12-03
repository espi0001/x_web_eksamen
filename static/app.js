const burger = document.querySelector(".burger");
const nav = document.querySelector("nav");

// ##############################
async function server(url, method, data_source_selector, function_after_fetch) {
  let conn = null;
  if (method.toUpperCase() == "POST") {
    const data_source = document.querySelector(data_source_selector);
    conn = await fetch(url, {
      method: method,
      body: new FormData(data_source),
    });
  }
  const data_from_server = await conn.text();
  if (!conn) {
    console.log("error connecting to the server");
  }
  window[function_after_fetch](data_from_server);
}

// ##############################
function get_search_results(url, method, data_source_selector, function_after_fetch) {
  const txt_search_for = document.querySelector("#txt_search_for");
  if (txt_search_for.value == "") {
    console.log("empty search");
    document.querySelector("#search_results").innerHTML = "";
    document.querySelector("#search_results").classList.add("d-none");
    return false;
  }
  server(url, method, data_source_selector, function_after_fetch);
}
// ##############################
function parse_search_results(data_from_server) {
  data_from_server = JSON.parse(data_from_server);

  let html_output = "";

  if (data_from_server.users && data_from_server.users.length) {
    data_from_server.users.forEach((user) => {
      let user_avatar_path = user.user_avatar_path ? user.user_avatar_path : "unknown.jpg";
      html_output += `
            <div class="d-flex a-items-center mb-2">
                <img src="/${user_avatar_path}" class="w-8 h-8 rounded-full" alt="Profile Picture">
                <div class="w-full ml-2">
                    <p>
                        ${user.user_first_name} ${user.user_last_name}
                        <span class="text-c-gray:+20 text-70">@${user.user_username}</span>
                    </p>                
                </div>
                <button class="px-4 py-1 text-c-white bg-c-black rounded-lg">Follow</button>
            </div>`;
    });
  }

  if (data_from_server.posts && data_from_server.posts.length) {
    data_from_server.posts.forEach((post) => {
      html_output += `
            <div class="search_post d-flex flex-col mb-2 p-2 bg-c-white">
                <p class="text-c-gray text-sm">${post.post_message}</p>
            </div>`;
    });
  }

  if (!html_output) {
    html_output = "<p>No results found.</p>";
  }

  const resultsContainer = document.querySelector("#search_results");
  resultsContainer.innerHTML = html_output;
  resultsContainer.classList.remove("d-none");
}

// ##############################
burger.addEventListener("click", () => {
  // toggle nav
  nav.classList.toggle("active");

  // toggle icon
  burger.classList.toggle("open");
});

// ==================== POST MEDIA PREVIEW ====================
document.addEventListener("DOMContentLoaded", function () {
  const fileInput = document.getElementById("post_media_input");
  const previewArea = document.getElementById("media_preview_area");
  const textarea = document.getElementById("post_textarea");
  const submitBtn = document.getElementById("post_submit_btn");

  // Enable/disable post button based on content
  if (textarea && submitBtn) {
    textarea.addEventListener("input", function () {
      submitBtn.disabled = textarea.value.trim().length === 0;
    });
  }

  // Handle file selection
  if (fileInput && previewArea) {
    fileInput.addEventListener("change", function (e) {
      const file = e.target.files[0];
      if (!file) return;

      // Clear previous preview
      previewArea.innerHTML = "";

      const fileURL = URL.createObjectURL(file);
      const fileType = file.type;

      // Create preview wrapper
      const wrapper = document.createElement("div");
      wrapper.className = "preview-wrapper";

      // Create media element
      if (fileType.startsWith("image/")) {
        const img = document.createElement("img");
        img.src = fileURL;
        img.alt = "Preview";
        wrapper.appendChild(img);
      } else if (fileType.startsWith("video/")) {
        const video = document.createElement("video");
        video.src = fileURL;
        video.controls = true;
        wrapper.appendChild(video);
      }

      // Create remove button
      const removeBtn = document.createElement("button");
      removeBtn.innerHTML = "×";
      removeBtn.className = "remove-preview-btn";
      removeBtn.type = "button";
      removeBtn.title = "Remove";
      removeBtn.onclick = function () {
        previewArea.innerHTML = "";
        fileInput.value = "";
      };

      wrapper.appendChild(removeBtn);
      previewArea.appendChild(wrapper);

      // Enable post button if textarea has content or file is selected
      if (submitBtn) {
        submitBtn.disabled = false;
      }
    });
  }
});
