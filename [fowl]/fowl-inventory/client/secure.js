onNet("inventory:cl_receiveCharacterInventory", function(inventory) {
    player.inv = inventory;
})
emitNet("inventory:sv_requestCharacterInventory")

var player = {
    inv : {},
    verifySlot : function(slot) {
        return (slot.id === player.inv[slot.index].item && slot.amount === player.inv[slot.index].amount);
    },
    move : function(itemSlot, targetSlot) {
        // Verify
        if (player.verifySlot(itemSlot)) {
            // Verify
            if ( player.inv[targetSlot.index] === "empty" ) {
                // Execute
                player.inv[targetSlot.index] = player.inv[itemSlot.index];
                player.inv[itemSlot.index] = "empty";
                return true;
            }
        }
        return false
    },
    swap : function (itemSlot, targetSlot) {
        // Verify
        if (player.verifySlot(itemSlot) && player.verifySlot(targetSlot)) {
            // Execute
            var item = player.inv[itemSlot.index];
            var target = player.inv[targetSlot.index];
    
            player.inv[itemSlot.index] = target;
            player.inv[targetSlot.index] = item;            
            return true
        }
        return false
    },
    math : function(itemSlot, targetSlot, amount, expectedItemAmount, expectedTargetAmount) {
        // Verify
        if (player.verifySlot(itemSlot) && player.verifySlot(targetSlot)) {
            var item = player.inv[itemSlot.index];
            var target = player.inv[targetSlot.index];
            
            // Verify
            if ( item.item === target.item ) {
                if ( amount < item.amount ) {
                    if ( (item.amount - amount === expectedItemAmount) && (target.amount + amount === expectedTargetAmount) ) {
                        // Execute
                        player.inv[itemSlot.index].amount = item.amount - amount;
                        player.inv[targetSlot.index].amount = target.amount + amount;
                        return true;
                    }
                }
            }
        }
        return false;
    },
    combine : function(itemSlot, targetSlot, expectedSum) {
        if ( player.verifySlot(itemSlot) && player.verifySlot(targetSlot) ){
            if ( itemSlot.id === targetSlot.id ) {
                if ( player.inv[itemSlot.index].amount + player.inv[targetSlot.index].amount === expectedSum ) {
                    player.inv[targetSlot.index].amount = expectedSum;
                    player.inv[itemSlot.index] = "empty";
                    return true
                }
            }
        }
        return false
    },
    split : function(itemSlot, targetSlot, amount, expectedSum) {
        // Verify
        var item = player.inv[itemSlot.index]
        if ( player.verifySlot(itemSlot) ) {
            if ( amount < item.amount ) {
                if ( item.amount - amount === expectedSum) {
                    var target = {}
                    Object.keys(player.inv[itemSlot.index]).forEach(function(key){
                        target[key] = player.inv[itemSlot.index][key]
                    })
                    target.amount = amount;
                    player.inv[targetSlot.index] = target;
                    player.inv[itemSlot.index].amount = expectedSum;    
                    return true
                }
            }
        }
        return false
    },
}




RegisterNuiCallbackType('player_swap');
on('__cfx_nui:player_swap', (data, cb) => {
    console.log("swap");
    cb(player.swap(data.item, data.target));
});

RegisterNuiCallbackType('player_move');
on('__cfx_nui:player_move', (data, cb) => {
    console.log("move");
    cb(player.move(data.item, data.target));
});

RegisterNuiCallbackType('player_math');
on('__cfx_nui:player_math', (data, cb) => {
    console.log("math");
    cb(player.math(data.item, data.target, data.amount, data.expectedItemAmount, data.expectedTargetAmount));
});
    
RegisterNuiCallbackType('player_combine');
on('__cfx_nui:player_combine', (data, cb) => {
    console.log("combine");
    cb(player.combine(data.item, data.target, data.expectedSum));
});

RegisterNuiCallbackType('player_split');
on('__cfx_nui:player_split', (data, cb) => {
    console.log("split");
    cb(player.split(data.item, data.target, data.amount, data.expectedSum));
});