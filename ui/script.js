var editing = false;
var prevContent = '';

$(document).ready(function() {
    window.addEventListener('message', function(event) {
        if (event.data.action == 'completeEdit') {
            let slot = $('div.slot[data-number="' + event.data.slot + '"]');
            if (slot.hasClass('empty')) {
                slot.removeClass('empty');
            }
            stopSlotEdit(slot, event.data.name);

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
                $('#info-icon').attr('src', 'https://nui-img/shared/info_icon_32')
                $('body').fadeIn();
                $('.main').fadeIn();
            }
            else {
                $('body').fadeOut();
                $('.main').fadeOut();
            }
        }
        else if (event.data.action == 'refresh') {
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
}

function cancelEdit(slot) {
    stopSlotEdit(slot, prevContent);
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

function stopSlotEdit(slot, name) {
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
        // TODO: play sound
        console.log('stop editing first!')
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
        let number = $(this).data('number');
        $.post('https://cui_wardrobe/load', JSON.stringify({
            slot: number,
        }));
    }
});