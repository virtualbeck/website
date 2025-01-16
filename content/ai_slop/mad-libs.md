---
title: "Mad Libs"
type: post
---

{{< rawhtml >}}
<form id="madlibsForm" method="POST" action="http://localhost:8081/submit">
    <label for="noun">Noun:</label>
    <select name="noun" id="noun">
        <option value="dog">Dog</option>
        <option value="cat">Cat</option>
        <option value="car">Car</option>
    </select><br>

    <label for="adjective">Adjective:</label>
    <select name="adjective" id="adjective">
        <option value="beautiful">Beautiful</option>
        <option value="funny">Funny</option>
        <option value="fast">Fast</option>
    </select><br>

    <label for="verb">Verb:</label>
    <select name="verb" id="verb">
        <option value="run">Run</option>
        <option value="jump">Jump</option>
        <option value="swim">Swim</option>
    </select><br>

    <input type="submit-mad-libs" value="Submit">
</form>
{{< /rawhtml >}}