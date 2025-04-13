using System;
using UnityEngine;
using UnityEngine.Serialization;

namespace Project.StencilTestCube.Scripts
{
    [ExecuteAlways]
    public class StencilSetting : MonoBehaviour
    {
        private MaterialPropertyBlock[] _blocks;
        [SerializeField] private Renderer[] rendererArray;
        [SerializeField] private float[] strengthArray;
        // [SerializeField] private int _stencilID;

        private void Awake()
        {
            _blocks = new MaterialPropertyBlock[10];
            for (int i = 0; i < _blocks.Length; i++)
            {
                _blocks[i] = new MaterialPropertyBlock();
            }
        }

        private void Update()
        {
            for (int i = 0; i < rendererArray.Length; i++)
            {
                _blocks[i].SetFloat("_Strength", strengthArray[i]);
                rendererArray[i].SetPropertyBlock(_blocks[i]);
            }
        }
    }
}