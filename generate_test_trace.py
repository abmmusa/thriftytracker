from pylibs import spatialfunclib

iterations=10

start_coord=(41.8720, -87.6400)
bearing=0.0
parking_time=3600
moving_time=900
distance_each_seconds=20.0 #meters/sec
start_epoch=1384929079.0

epoch = start_epoch
switch_epoch = epoch + moving_time - 1
dest_coord = (start_coord[0], start_coord[1])


i=0
while i<=iterations:
    if i%2==0: #moving
        dest_coord=spatialfunclib.destination_point(dest_coord[0], dest_coord[1], bearing, distance_each_seconds)
        print dest_coord[0], dest_coord[1], epoch, None, bearing, None, None, None, None, None
        

        if epoch >= switch_epoch:
            switch_epoch=epoch+parking_time
            i=i+1

    else: #parked
        print dest_coord[0], dest_coord[1], epoch, None, bearing, None, None, None, None, None

        if epoch >= switch_epoch:
            switch_epoch=epoch+moving_time
            i=i+1
            

    epoch = epoch+1.0

