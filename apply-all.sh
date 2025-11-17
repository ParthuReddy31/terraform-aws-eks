#!/bin/bash
set -e

echo "======================================"
echo "Applying Terraform in Correct Order"
echo "======================================"

# Array of directories in dependency order
DIRS=("00-vpc" "10-sg" "20-bastion" "30-rds" "40-eks")

for dir in "${DIRS[@]}"; do
  echo ""
  echo "========================================="
  echo "📁 Applying: $dir"
  echo "========================================="
  cd "$dir"
  
  # Always run init with upgrade to handle module source changes
  echo "Initializing..."
  terraform init -upgrade
  
  # Apply
  terraform apply -auto-approve
  
  # Check exit code
  if [ $? -eq 0 ]; then
    echo "✅ $dir completed successfully"
  else
    echo "❌ $dir failed!"
    exit 1
  fi
  
  cd ..
done

echo ""
echo "========================================="
echo "✅ All Terraform applies completed!"
echo "========================================="
