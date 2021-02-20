        BUILDER_IMAGE=one-vision-builder-pipeline

        if test $BUILDER_IMAGE; then
            echo "Checking if builder image is up to date with deps from the repo..."

            PIPELINE_RESULT=$(curl -F 'data=@package.json' http://34.91.15.31:1000/check?name=$BUILDER_IMAGE)

            if test $PIPELINE_RESULT; then
                echo "Please Update builder pipeline... !!!"
                echo $PIPELINE_RESULT
                exit 1
            fi
        fi