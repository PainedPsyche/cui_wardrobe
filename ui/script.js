var editing = false;
var prevContent = '';
var model = 'unknown'

$(document).ready(function() {
    window.addEventListener('message', function(event) {
        if (event.data.action == 'completeEdit') {
            let slot = $('div.slot[data-number="' + event.data.slot + '"]');
            if (slot.hasClass('empty')) {
                slot.removeClass('empty');
            }
            stopSlotEdit(slot, event.data.name, true);

            if (slot.find('button.clear').length == 0)
            {
                let editbutton = slot.find('button.edit');
                $('<button class="clear"></button>').insertAfter(editbutton);
            }
        }
        else if (event.data.action == 'completeDeletion') {
            let slot = $('div.slot[data-number="' + event.data.slot + '"]');
            clearSlot(slot);
        }
        else if (event.data.action == 'setVisible') {
            if (event.data.value) {
                $('#info-icon').attr('src', 'https://nui-img/shared/info_icon_32');
                tooltip.text(info.default);
                $('body').fadeIn();
                $('.main').fadeIn();
            }
            else {
                $('body').fadeOut();
                $('.main').fadeOut();
            }
        }
        else if (event.data.action == 'refresh') {
            model = event.data.model;
            $('#outfit-list').html(event.data.html);
        }
        else if (event.data.action == 'abortDeletion') {
            editing = false;
        }
    });
});

function refocus(element) {
    element.focus();
}

function showEditPanel(slot, clearable) {
    let controls = slot.find('.controls');
    controls.empty();
    controls.append($('<button class="edit"></button>'));

    if (clearable) {
        controls.append($('<button class="clear"></button>'));
    }
}

function showConfirmPanel(slot, confirmCallback, cancelCallback) {
    let controls = slot.find('.controls');
    let acceptbutton = $('<button class="accept"></button>');
    let cancelbutton = $('<button class="cancel"></button>');

    acceptbutton[0].addEventListener('click', function(event) {
        confirmCallback(slot);
    });
    cancelbutton[0].addEventListener('click', function(event) {
        cancelCallback(slot);

        /*  NOTE: (Workaround)

            For some reason this button's sound does not play
            when clicked without this. 

            Possibly the button is removed too fast?
        */
        $.post('https://cui_wardrobe/playSound', JSON.stringify({
            sound: 'smallbuttonclick'
        }));
    });

    controls.empty();
    controls.append(acceptbutton);
    controls.append(cancelbutton);
}

function confirmEdit(slot) {
    let input = slot.find('.slot-input');
    let name = input.val().trim();
    if (name) {
        $.post('https://cui_wardrobe/save', JSON.stringify({
            slot: slot.data('number'),
            name: name
        }));
    }
    else {
        $.post('https://cui_wardrobe/playSound', JSON.stringify({
            sound: 'error'
        }));
    }
}

function cancelEdit(slot) {
    stopSlotEdit(slot, prevContent, false);
}

function confirmClear(slot) {
    $.post('https://cui_wardrobe/clear', JSON.stringify({
        slot: slot.data('number'),
    }));
}

function cancelClear(slot) {
    if (slot.hasClass('active')) {
        slot.removeClass('active');
    }

    slot.siblings().each(function() {
        $(this).css('pointer-events', 'auto');
    });

    showEditPanel(slot, true);

    editing = false;
}

function stopSlotEdit(slot, name, accepted) {
    if (slot.hasClass('active')) {
        slot.removeClass('active');
    }

    let input = slot.find('.slot-input');
    let content = name;
    let empty = slot.hasClass('empty');
    if (!content.trim()) {
        content = 'Empty slot'
    }
    let text = $('<span class="slot-text">' + content + '</span>');

    input.replaceWith(text);

    slot.siblings().each(function() {
        $(this).css('pointer-events', 'auto');
    });

    showEditPanel(slot, !empty);

    slot.trigger('editstopped', [accepted]);
    editing = false;
}

function startSlotEdit(slot) {
    if (!(slot.hasClass('active'))) {
        slot.addClass('active');
    }

    showConfirmPanel(slot, confirmEdit, cancelEdit);

    let empty = slot.hasClass('empty');
    let text = slot.find('.slot-text');
    let input = $('<input class="slot-input" type="text" maxlength="25" spellcheck="false" placeholder="(max. 25 characters)" onblur="refocus(this)">');
    prevContent = text.text();

    if (!empty) {
        input.val(prevContent);
    }

    text.replaceWith(input);

    slot.siblings().each(function() {
        $(this).css('pointer-events', 'none');
    });

    input[0].addEventListener('keyup', function(event) {
        if (event.keyCode === 13) {
            confirmEdit(slot);
        }
        else if (event.keyCode === 27) {
            cancelEdit(slot);
        }
    });
    input.focus();

    slot.trigger('editstarted');
    editing = true;
}

function clearSlot(slot) {
    if (slot.hasClass('active')) {
        slot.removeClass('active');
    }
    if (!(slot.hasClass('empty'))) {
        slot.addClass('empty');
    }

    showEditPanel(slot, false);
    slot.find('.slot-text').text('Empty slot');

    slot.siblings().each(function() {
        $(this).css('pointer-events', 'auto');
    });

    editing = false;
}

$('#exit').on('click', function(event) {
    if(!editing) {
        $.post('https://cui_wardrobe/close', JSON.stringify({
        }));
    }
    else {
        $.post('https://cui_wardrobe/playSound', JSON.stringify({
            sound: 'error'
        }));
    }
});

$('#outfit-list').on('click', 'button.edit', function(event) {
    if (!editing) {
        let slot = $(this).parents().eq(1);
        startSlotEdit(slot);
    }
});

$('#outfit-list').on('click', 'button.clear', function(event) {
    if (!editing) {
        let slot = $(this).parents().eq(1);

        if (!(slot.hasClass('active'))) {
            slot.addClass('active');
        }

        showConfirmPanel(slot, confirmClear, cancelClear);

        slot.siblings().each(function() {
            $(this).css('pointer-events', 'none');
        });

        editing = true;
    }
});

$('#outfit-list').on('click', 'div.slot', function(event) {
    if (!editing) {
        let compatibleModel = (model == $(this).data('gender'));
        if ($(this).hasClass('empty') || !compatibleModel) {
            $.post('https://cui_wardrobe/playSound', JSON.stringify({
                sound: 'error'
            }));
        }
        else {
            let number = $(this).data('number');
            $.post('https://cui_wardrobe/load', JSON.stringify({
                slot: number,
            }));
            $.post('https://cui_wardrobe/playSound', JSON.stringify({
                sound: 'changeoutfit'
            }));
        }
    }
});

// Tooltips
var tooltip = $('#info-text');
const info = {
    default: 'Highlight a slot for more options.',
    change: 'Click to change to this outfit.',
    empty: 'Click the edit button to save your current outfit in this slot.',
    editbutton: 'Edit this slot.',
    clearbutton: 'Clear this slot.',
    confirmbutton: 'Confirm.',
    cancelbutton: 'Cancel.',
    closebutton: 'Close the wardrobe.'
};

$('#outfit-list').on('mouseenter', 'div.slot', function() {
    if (!editing) {
        if ($(this).hasClass('empty')) {
            tooltip.text(info.empty);
        }
        else {
            tooltip.text(info.change);
        }
    }
});

$('#outfit-list').on('mouseenter', 'button.edit', function() {
    tooltip.text(info.editbutton);
});

$('#outfit-list').on('mouseenter', 'button.clear', function() {
    tooltip.text(info.clearbutton);
});

$('#outfit-list').on('mouseenter', 'button.accept', function() {
    tooltip.text(info.confirmbutton);
});

$('#outfit-list').on('mouseenter', 'button.cancel', function() {
    tooltip.text(info.cancelbutton);
});

$('#outfit-list').on('mouseleave', 'button', function() {
    $(this).parents().eq(1).trigger('mouseenter');
});

$('#outfit-list').on('mouseleave', 'div.slot', function() {
    tooltip.text(info.default);
});

$('#bottom-panel').on('mouseenter', '#exit', function() {
    tooltip.text(info.closebutton);
});

$('#bottom-panel').on('mouseleave', '#exit', function() {
    tooltip.text(info.default);
});

// Sounds
$('#outfit-list').on('click', 'button', function() {
    $.post('https://cui_wardrobe/playSound', JSON.stringify({
        sound: 'smallbuttonclick'
    }));
});

$('#bottom-panel').on('click', 'button', function() {
    $.post('https://cui_wardrobe/playSound', JSON.stringify({
        sound: 'panelbuttonclick'
    }));
});

