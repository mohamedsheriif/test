#!/bin/bash

number_of_digests_to_keep=5

# List all Azure Container Registries
# ACR_NAMES=$(az acr list --query "[].name" -o tsv)

# ACR_NAMES=("skolerastage" "skoleraprod")
ACR_NAME="skolerastage"
#for ACR_NAME in $(ACR_NAMES[@]); do
echo ">>> Processing ACR: $ACR_NAME"
# List repositories in the current ACR
REPOS=$(az acr repository list --name "$ACR_NAME" --output tsv)
for repo in $REPOS; do
  echo "  > Repository: $repo"
  # Get full repo ID (ACR login server)
  LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query "loginServer" -o tsv)
  FULL_REPO="$LOGIN_SERVER/$repo"
  # List digests using the correct full repo ID
  DIGESTS=$(az acr manifest list-metadata "$FULL_REPO" \
    --orderby time_desc \
    --query "[].digest" \
    --output tsv)
  DIGEST_ARRAY=($DIGESTS)
  TOTAL_DIGESTS=${#DIGEST_ARRAY[@]}
  if [ "$TOTAL_DIGESTS" -le $number_of_digests_to_keep ]; then
    echo "    Skipping — only $TOTAL_DIGESTS digest(s) found."
    continue
  fi
  KEEP_DIGESTS=("${DIGEST_ARRAY[@]:0:$number_of_digests_to_keep}")
  DELETE_DIGESTS=("${DIGEST_ARRAY[@]:$number_of_digests_to_keep}")
  echo "    Keeping latest $number_of_digests_to_keep digests. Deleting ${#DELETE_DIGESTS[@]}..."
  for digest in "${KEEP_DIGESTS[@]}"; do
    echo "      Keeping digest: $digest"
  
  done
  for digest in "${DELETE_DIGESTS[@]}"; do
    echo "      Deleting digest: $digest"
    # az acr repository delete \
    #   --name "$ACR_NAME" \
    #   --image "$repo@$digest" \
    #   --yes
  done  
done