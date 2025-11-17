#!/bin/bash
set -e

DIRS=("40-eks" "30-rds" "20-bastion" "10-sg" "00-vpc")

for dir in "${DIRS[@]}"; do
  echo "========================================="
  echo "🗑️  Destroying: $dir"
  echo "========================================="
  cd "$dir" || exit 1
  terraform destroy -auto-approve
  if [ $? -eq 0 ]; then
    echo "✅ $dir destroyed successfully"
  else
    echo "❌ $dir destroy failed"
    exit 1
  fi
  cd ..
  echo ""
done

echo "✅ All resources destroyed successfully!"
