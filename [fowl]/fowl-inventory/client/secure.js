var inv;

onNet("inventory:cl_receiveCharacterInventory", function(inventory) {
    inv = inventory;
})
emitNet("inventory:sv_requestCharacterInventory")

function verifySlot(slot){
    return (slot.id === inv[slot.index].item && slot.amount === inv[slot.index].amount);
}
function player_move(itemSlot, targetSlot) {
    // Verify
    if (verifySlot(itemSlot)) {
        // Verify
        if ( inv[targetSlot.index] === "empty" ) {
            // Execute
            inv[targetSlot.index] = inv[itemSlot.index];
            inv[itemSlot.index] = "empty";
            console.log(inv);
            return true;
        }
    }
    return false
}
function player_swap(itemSlot, targetSlot) {
    // Verify
    if (verifySlot(itemSlot) && verifySlot(targetSlot)) {
        // Execute
        var item = inv[itemSlot.index];
        var target = inv[targetSlot.index];

        inv[itemSlot.index] = target;
        inv[targetSlot.index] = item;
        
        console.log(inv);
        return true
    }
    return false
}
function player_math(itemSlot, targetSlot, amount, expectedItemAmount, expectedTargetAmount) {
    // Verify
    if (verifySlot(itemSlot) && verifySlot(targetSlot)) {
        var item = inv[itemSlot.index];
        var target = inv[targetSlot.index];
        
        // Verify
        if ( item.item === target.item ) {
            if ( amount < item.amount ) {
                if ( (item.amount - amount === expectedItemAmount) && (target.amount + amount === expectedTargetAmount) ) {
                    // Execute
                    inv[itemSlot.index].amount = item.amount - amount;
                    inv[targetSlot.index].amount = target.amount + amount;
                    console.log(inv);
                    return true;
                }
            }
        }
    }
    return false;
}
function player_combine(itemSlot, targetSlot, expectedSum) {
    if ( verifySlot(itemSlot) && verifySlot(targetSlot) ){
        if ( itemSlot.id === targetSlot.id ) {
            if ( inv[itemSlot.index].amount + inv[targetSlot.index].amount === expectedSum ) {
                inv[targetSlot.index].amount = expectedSum;
                inv[itemSlot.index] = "empty";
                console.log(inv);
                return true
            }
        }
    }
    return false
}
function player_split(itemSlot, targetSlot, amount, expectedSum) {
    // Verify
    var item = inv[itemSlot.index]
    if ( verifySlot(itemSlot) ) {
        if ( amount < item.amount ) {
            if ( item.amount - amount === expectedSum) {
                var target = {}
                Object.keys(inv[itemSlot.index]).forEach(function(key){
                    target[key] = inv[itemSlot.index][key]
                })
                target.amount = amount;
                inv[targetSlot.index] = target;
                inv[itemSlot.index].amount = expectedSum;

                console.log(inv);
                return true
            }
        }
    }
    return false
}

RegisterNuiCallbackType('player_swap');
on('__cfx_nui:player_swap', (data, cb) => {
    console.log("swap");
    cb(player_swap(data.item, data.target));
});

RegisterNuiCallbackType('player_move');
on('__cfx_nui:player_move', (data, cb) => {
    console.log("move");
    cb(player_move(data.item, data.target));
});

RegisterNuiCallbackType('player_math');
on('__cfx_nui:player_math', (data, cb) => {
        console.log("math");
        cb(player_math(data.item, data.target, data.amount, data.expectedItemAmount, data.expectedTargetAmount));
});
    
RegisterNuiCallbackType('player_combine');
on('__cfx_nui:player_combine', (data, cb) => {
    console.log("combine");
    cb(player_combine(data.item, data.target, data.expectedSum));
});

RegisterNuiCallbackType('player_split');
on('__cfx_nui:player_split', (data, cb) => {
    console.log("split");
    cb(player_split(data.item, data.target, data.amount, data.expectedSum));
});