using System;
using UnityEngine;

[ExecuteInEditMode]
public class LinearAlgebra : MonoBehaviour
{
    private float _updateTimeInterval = 3f;
    private float _currentTime = 0;

    private void Update()
    {
        _currentTime += Time.deltaTime;
        if (_updateTimeInterval - _currentTime <= 0.05f)
        {
            Debug.Log("Hi");
            _currentTime = 0;
        }
    }
}