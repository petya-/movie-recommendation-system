var userID = db.ratings.distinct("userId")
userID.forEach(id => {
    db.users.insert ({
        userId : id
    });
});