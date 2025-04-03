using UnityEngine;

public class Normal : MonoBehaviour
{
    [SerializeField] private Transform _sunObject;
    [SerializeField] private Transform _localObject;
    [SerializeField] private Transform _targetObject;
    [SerializeField] private Transform _sunDirection;
    [SerializeField] private Transform _localDirection;
    [SerializeField] private Transform _targetDirection;

    private void OnDrawGizmos()
    {
        Vector3 sun = _sunObject.position;
        Vector3 local = _localObject.position;
        Vector3 target = _targetObject.position;
        // Connection
        Gizmos.color = Color.blue;
        Gizmos.DrawLine(local, target);
        Gizmos.color = Color.red;
        Gizmos.DrawLine(sun, local);
        Gizmos.color = Color.magenta;
        Gizmos.DrawLine(local, Vector3.Cross(local, target).normalized * 10f);
        Gizmos.color = Color.green;
        Vector3 localToSun = local - sun;
        Vector3 localToTarget = local - target;
        Gizmos.DrawLine(local, Vector3.Cross(localToSun, localToTarget));
        Vector3 sunToLocal = sun - local;
        Vector3 targetToLocal = target - local;
        Gizmos.DrawLine(local, Vector3.Cross(sunToLocal, targetToLocal));
    }
}