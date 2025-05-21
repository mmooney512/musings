$(document).ready(function() {
    // Make the table body sortable
    $("#itemsTable tbody").sortable({
        update: function() {
            const sortedOrder = $("#itemsTable tbody tr").map(function() {
                return $(this).data("id");
            }).get();
            $("#reorderedItems").val(JSON.stringify(sortedOrder));
        }
    });

    // Toggle selection on click (but not on edit or save icons)
    $("#itemsTable tbody").on("click", "tr", function(e) {
        if ($(e.target).hasClass("edit-icon") || $(e.target).hasClass("save-icon")) {
            return; // Do nothing if the click is on an icon
        }
        $(this).toggleClass("selected");
    });

    // Move the row to the top of the table when the up arrow image is clicked
    $("#itemsTable tbody").on("click", ".move-to-top-icon", function() {
        const row = $(this).closest("tr");
        row.fadeOut(300, function() {
            $(this).prependTo("#itemsTable tbody").fadeIn(300, function() {
                $(this).addClass("selected");
            });
        });
    });

    // Submit the selected and ordered Items
    $("#submitReorderedItems").click(function() {
        const selectedItems = $("#itemsTable tbody tr.selected").map(function() {
            return $(this).data("id");
        }).get();

        $("#reorderedItems").val(JSON.stringify(selectedItems));
        $("#reorderForm").submit();
    });

    // Handle the Add Item form submission using AJAX
    $("#addItemForm").submit(function(event) {
        event.preventDefault();  // Prevent page reload

        const groupName = $("#groupName").val();
        const itemText = $("#itemText").val();
        const itemType = $("#itemType").val();
        const placeHolderName = $("#placeHolderName").val();

        $.post(addItemUrl, {
            item_type: itemType,
            group_name: groupName,
            item_text: itemText,
            placeholder_name: placeHolderName
        }).done(function(data) {
            // create the skill row
            const newRow = $(`
                <tr class="item-row" data-id="${data.id}">
                    <td>
                        <img class="move-to-top-icon" alt="Move to Top" title="Move to Top" src="/static/arrow-up-circle.png"/>
                        <img class="edit-icon" alt="Edit" title="Edit" src="/static/edit_icon.png" />
                    </td>
                    <td>${data.group_name}</td>
                    <td>${data.item_text}</td>
                </tr>
            `);
            
            // Add the new row to the top of the table
            $("#itemsTable tbody").prepend(newRow);

            // Select the new row
            newRow.addClass("selected");

            // Clear the form inputs
            $("#groupName").val('');
            $("#itemText").val('');
        }).fail(function() {
            alert("Error adding item. Please try again.");
        });
    });

    // Edit the row
    $("#itemsTable tbody").on("click", ".edit-icon", function () {
        const row = $(this).closest("tr");
        const groupNameCell = row.find(".group-name");
        const itemTextCell = row.find(".item-text");

        // Save the current values
        const currentGroupName = groupNameCell.text().trim();
        const currentItemText = itemTextCell.text().trim();

        // Replace cell contents with input fields
        groupNameCell.html(`<input type="text" class="edit-input group-edit" value="${currentGroupName}" />`);
        itemTextCell.html(`<input type="text" class="edit-input item-edit" value="${currentItemText}" />`);

        // Hide the Edit icon and show the Save icon
        row.find(".move-to-top-icon").hide();
        row.find(".edit-icon").hide();
        row.find(".save-icon").show();
        row.find(".delete-icon").show();
    });


    // Save the edited row
    $("#itemsTable tbody").on("click", ".save-icon", function () {
        const row = $(this).closest("tr");
        const itemType = $("#itemType").val();
        const itemId = row.data("id");
        const groupNameInput = row.find(".group-edit");
        const itemTextInput = row.find(".item-edit");

        const updatedGroupName = groupNameInput.val().trim();
        const updatedItemText = itemTextInput.val().trim();

        // Send the updated data to the server
        $.post(updateItemUrl, {
            item_type: itemType,
            item_id: itemId,
            group_name: updatedGroupName,
            item_text: updatedItemText
        }).done(function () {
            // Replace input fields with updated text
            row.find(".group-name").text(updatedGroupName);
            row.find(".item-text").text(updatedItemText);

            // Hide the Save icon and show the Edit icon
            row.find(".save-icon").hide();
            row.find(".delete-icon").hide();
            row.find(".move-to-top-icon").show();
            row.find(".edit-icon").show();
        }).fail(function () {
            alert("Error saving item. Please try again.");
        });
    });

    // Delete the row
    $("#itemsTable tbody").on("click", ".delete-icon", function () {
        const row = $(this).closest("tr");
        const itemType = $("#itemType").val();
        const itemId = row.data("id");

        if (confirm("Are you sure you want to delete this item?")) {
            $.post(deleteItemUrl, {
                item_type: itemType,
                item_id: itemId
            }).done(function () {
                    // Remove the row from the table
                    row.fadeOut(300, function () {
                        $(this).remove();
                    });
                })
                .fail(function () {
                    alert("Error deleting item. Please try again.");
                });
        }
    });


});