---
title: Pinterest Image Extractor
date: 2025-01-22
---

## Extract Pinterest Original Image
Please input a Pinterest URL below, and we'll fetch the original image for you:

<form id="pinterest-form">
    <label for="url">Pinterest URL:</label>
    <input type="text" id="url" name="url" placeholder="Enter Pinterest URL" required
           pattern="https:\/\/www\.pinterest\.com\/pin\/.*" title="URL must be a valid Pinterest pin URL" />
    <button type="submit">Submit</button>
</form>

<div id="result">
    <!-- Image or error message will be displayed here -->
</div>

<script>
document.getElementById('pinterest-form').addEventListener('submit', function(event) {
    event.preventDefault();

    var url = document.getElementById('url').value;

    fetch('http://localhost:5000/extract-image', {
        method: 'POST',
        body: new URLSearchParams({ url: url })
    })
    .then(response => response.json())
    .then(data => {
        if (data.image_url) {
            document.getElementById('result').innerHTML = `<h2>Original Image:</h2><img src="${data.image_url}" alt="Pinterest Image" />`;
        } else if (data.error) {
            document.getElementById('result').innerHTML = `<p>${data.error}</p>`;
        }
    })
    .catch(error => {
        document.getElementById('result').innerHTML = `<p>An error occurred: ${error}</p>`;
    });
});
</script>
