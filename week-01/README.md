strong {  
    color: #FFE4E1;  
    size: 100px;  
    margin: 0em;  
    font-size: xx-large;  
    font-style: italic;  
}  
## 1.实现一个自定义的classloader，加载如下的文件，内容需要解码，读取的字节码需要解码，解码方式：255减去原有值，并执行成功。📎Hello.xlass.zip  
package classloader;   

/**  
 * fshows.com  
 * Copyright {C} 2013-2020 All Rights Reserved  
 */  
  
import cn.hutool.core.io.resource.ClassPathResource;  
import cn.hutool.core.util.ReflectUtil;  
import cn.hutool.core.util.StrUtil;  
import com.sun.tools.javac.util.StringUtils;  
  
/**  
 * @author zhangxj  
 * @version classloader.NewClassLoader.java, v 0.1 2020-11-04 8:52 下午 zhangxj  
 */  
public class NewClassLoader extends ClassLoader{  
  
    @Override  
    public Class<?> findClass(String name) throws ClassNotFoundException{  
        try {  
            ClassPathResource classPathResource = new ClassPathResource("classpath:" + name + ".xlass");  
            byte[] bytes = classPathResource.readBytes();  
            byte[] newBytes = new byte[bytes.length];  
            for (int i=0;i<bytes.length;i++) {  
                newBytes[i] = (byte)((byte)255-bytes[i]);  
            }  
            return defineClass(name, newBytes, 0, newBytes.length);  
        } catch (Exception e) {  
            e.printStackTrace();  
            throw new ClassNotFoundException();  
        }  
    }  
}  
  
class ClassLoaderTest {  
    public static void main(String[] args) throws Exception{  
        String name = "hello";  
        NewClassLoader classLoader = new NewClassLoader();  
        Class<?> clazz = Class.forName(StrUtil.upperFirst(name), true, classLoader);  
        Object object  = clazz.newInstance();  
        ReflectUtil.invoke(object, StringUtils.toLowerCase(name));  
    }  
}  
  
  
## 2.分析以下GC日志，尽可能详细的标注出GC发生时相关的信息。  
2020-10-29T21:19:19.488+0800: 114.015: [GC (CMS Initial Mark) [1 CMS-initial-mark: 106000K(2097152K)] 1084619K(3984640K), 0.2824583 secs] [Times: user=0.86 sys=0.00, real=0.28 secs]  
    <strong>2020-10-29T21:19:19.488+0800 – GC发生的时间；</strong>    
    <strong>114.015 – GC开始，相对JVM启动的相对时间，单位是秒；</strong>    
    <strong>GC – 区别MinorGC和FullGC的标识，这次代表的是MinorGC; </strong>   
    <strong>CMS Initial Mark – CMS初始标记</strong>  
    <strong>106000K(2097152K) - 当前老年代使用情况106000K，老年代可用容量2097152K；</strong>   
    <strong>1084619K(3984640K) - 当前整个堆的使用情况1084619K，整个堆总容量3984640K；</strong>    
    <strong>0.2824583 secs - 共耗时0.2824583秒</strong>  
    <strong>[Times: user=0.86 sys=0.00, real=0.28 secs] - 时间计量</strong>  
    <strong>user - 整个过程GC耗费的全部CPU时间0.86</strong> 
    <strong>sys - 操作系统调用或等待系统事件所花费的时间0.00</strong> 
    <strong>real - 应用程序从开始到结束消耗的总时间为0.28秒，因为多核的原故</strong> 
2020-10-29T21:19:19.771+0800: 114.298: [CMS-concurrent-mark-start]  
    <strong>CMS-concurrent-mark-start - 并发标记开始</strong> 
2020-10-29T21:19:19.931+0800: 114.458: [CMS-concurrent-mark: 0.160/0.160 secs] [Times: user=0.32 sys=0.03, real=0.16 secs]  
    <strong>CMS-concurrent-mark - 并发标记，总共花费0.160秒，cpu时间/0.160秒时钟时间</strong> 
2020-10-29T21:19:19.931+0800: 114.459: [CMS-concurrent-preclean-start]  
    <strong>CMS-concurrent-preclean-start - CMS可终止的并发预清理开始</strong> 
2020-10-29T21:19:19.998+0800: 114.525: [CMS-concurrent-preclean: 0.065/0.066 secs] [Times: user=0.05 sys=0.01, real=0.06 secs]  
    <strong>CMS-concurrent-preclean: 0.065/0.066 secs - CMS预清理，总共花费0.065秒，cpu时间/0.066秒时钟时间</strong> 
2020-10-29T21:19:19.998+0800: 114.525: [CMS-concurrent-abortable-preclean-start]CMS: abort preclean due to time   
    <strong>CMS-concurrent-abortable-preclean-start - 并发可被中止的预清理开始</strong>  
    <strong>CMS: abort preclean due to time - log</strong> 
2020-10-29T21:19:25.072+0800: 119.599: [CMS-concurrent-abortable-preclean: 5.038/5.073 secs] [Times: user=7.72 sys=0.50, real=5.08 secs]  
    <strong>CMS-concurrent-abortable-preclean: 5.038/5.073 secs - CMS并发可被中止的预清理，总共花费5.038秒，cpu时间/5.073秒时钟时间</strong> 
2020-10-29T21:19:25.076+0800: 119.603: [GC (CMS Final Remark) [YG occupancy: 1279357 K (1887488 K)]  
    <strong>GC (CMS Final Remark) - CMS收集阶段，这个阶段会标记老年代全部的存活对象，包括那些在并发标记阶段更改的或者新创建的引用对象</strong> 
    <strong>YG occupancy: 1279357 K (1887488 K) - 当前年轻代使用情况1279357K,年轻代可用总容量1887488K</strong> 
2020-10-29T21:19:25.076+0800: 119.603: [Rescan (parallel) , 0.3120602 secs]  
    <strong>Rescan (parallel) , 0.3120602 secs - 在应用暂停后重新并发标记所有存活对象，总共耗时0.3120602秒</strong> 
2020-10-29T21:19:25.388+0800: 119.915: [weak refs processing, 0.0015920 secs]  
    <strong>weak refs processing, 0.0015920 secs - 子阶段1—处理弱引用，共耗时0.0015920秒</strong> 
2020-10-29T21:19:25.390+0800: 119.917: [class unloading, 0.0517863 secs]  
    <strong>class unloading, 0.0517863 secs - 子阶段2—卸载无用的class，共耗时0.0517863秒</strong> 
2020-10-29T21:19:25.441+0800: 119.969: [scrub symbol table, 0.0212825 secs]  
    <strong>scrub symbol table, 0.0212825 secs - 子阶段3-清理symbol table(符号表)，共耗时0.0212825秒</strong> 
2020-10-29T21:19:25.463+0800: 119.990: [scrub string table, 0.0022435 secs][1 CMS-remark: 106000K(2097152K)] 1385358K(3984640K), 0.3959182 secs] [Times: user=1.33 sys=0.00, real=0.40 secs]  
    <strong>scrub string table, 0.0022435 secs - 最后阶段-清除字符表(存储类级别元数据)和字符串表(存储驻留字符串)，共耗时0.0022435秒</strong> 
    <strong>CMS-remark: 106000K(2097152K)] 1385358K(3984640K), 0.3959182 secs - 重新标记，当前老年代使用情况106000K，老年代可用总容量2097152K，当前整个堆使用情况1385358K，整个堆总容量3984640K，共耗时0.3959182秒</strong>   
2020-10-29T21:19:25.473+0800: 120.000: [CMS-concurrent-sweep-start]  
    <strong>CMS-concurrent-sweep-start - 并发清除开始</strong> 
2020-10-29T21:19:25.540+0800: 120.067: [CMS-concurrent-sweep: 0.067/0.067 secs] [Times: user=0.18 sys=0.02, real=0.06 secs]  
    <strong>CMS-concurrent-sweep: 0.067/0.067 secs - 并发清理总共耗时0.067秒，cpu时间/0.067秒时钟时间</strong> 
2020-10-29T21:19:25.540+0800: 120.068: [CMS-concurrent-reset-start]  
    <strong>CMS-concurrent-reset-start - 并发重置开始</strong> 
2020-10-29T21:19:25.544+0800: 120.071: [CMS-concurrent-reset: 0.003/0.003 secs] [Times: user=0.00 sys=0.00, real=0.01 secs]  
    <strong>CMS-concurrent-reset: 0.003/0.003 secs - 并发重置总共耗时0.003秒，cpu时间/0.003秒时钟时间</strong>  
      
## 3. 标注以下启动参数每个参数的含义  
java   
-Denv=PRO <strong>指定 Spring Boot profile 环境 PRO</strong>  
-server <strong>服务端模式</strong>  
-Xms4g <strong>设置jvm堆内存最小为4g</strong>  
-Xmx4g <strong>设置jvm堆内存最大为4g</strong>  
-Xmn2g <strong>设置年轻代 (新生代) jvm堆内存为2g</strong>  
-XX:MaxDirectMemorySize=512m <strong>设置jvm堆外内存大小为512M</strong>   
-XX:MetaspaceSize=128m <strong>设置jvm元数据区空间128M,到Java8时, Metaspace(元数据区) 取代 PermGen space(永久代), 用来存放class信息</strong>    
-XX:MaxMetaspaceSize=512m <strong>设置jvm元数据区最大空间512M</strong>    
-XX:-UseBiasedLocking <strong>关闭偏向锁</strong>    
-XX:-UseCounterDecay <strong>禁止JIT调用计数器衰减</strong>    
-XX:AutoBoxCacheMax=10240 <strong>设置jvm自动装箱的最大范围10240</strong>    
-XX:+UseConcMarkSweepGC <strong>设置jvm老年代使用CMS收集器</strong>    
-XX:CMSInitiatingOccupancyFraction=75 <strong>计算老年代最大使用率，使用cms作为垃圾回收，使用75％后开始CMS收集</strong>    
-XX:+UseCMSInitiatingOccupancyOnly <strong>设置CMS收集仅在内存占用率达到时再触发</strong>    
-XX:MaxTenuringThreshold=6 <strong>设置对象在新生代中最大的存活次数为6就晋升到老生代</strong>    
-XX:+ExplicitGCInvokesConcurrent <strong>使用System.gc()时触发CMS GC，而不是Full GC</strong>    
-XX:+ParallelRefProcEnabled <strong>默认为false，并行的处理Reference对象，如WeakReference，除非在GC log里出现Reference处理时间较长的日志，否则效果不会很明显。</strong>    
-XX:+PerfDisableSharedMem <strong>禁止写统计文件</strong>    
-XX:+AlwaysPreTouch <strong>JAVA进程启动的时候,虽然我们可以为JVM指定合适的内存大小,但是这些内存操作系统并没有真正的分配给JVM,而是等JVM访问这些内存的时候,才真正分配；通过配置这个参数JVM就会先访问所有分配给它的内存,让操作系统把内存真正的分配给JVM.从而提高运行时的性能，后续JVM就可以更好的访问内存了；</strong>    
-XX:-OmitStackTraceInFastThrow  <strong>强制要求JVM始终抛出含堆栈的异常</strong>    
-XX:+ExplicitGCInvokesConcurrent <strong>命令JVM无论什么时候调用系统GC，都执行CMS GC，而不是Full GC</strong>    
-XX:+HeapDumpOnOutOfMemoryError  <strong>当堆内存空间溢出时输出堆的内存快照。</strong>    
-XX:HeapDumpPath=/home/devjava/logs/ <strong>设置堆内存空间溢出是内存快照保存路径 </strong>   
-Xloggc:/home/devjava/logs/lifecircle-tradecore-gc.log <strong>将gc垃圾回收信息输出到指定文件</strong>    
-XX:+PrintGCApplicationStoppedTime <strong>打印gc垃圾回收期间程序暂停的时间</strong>    
-XX:+PrintGCDateStamps <strong>打印GC执行的时间戳</strong>   
-XX:+PrintGCDetails <strong>打印GC日志详情</strong>    
-javaagent:/home/devjava/ArmsAgent/arms-bootstrap-1.7.0-SNAPSHOT.jar <strong>加载arms的包</strong>    
-jar /home/devjava/lifecircle-tradecore/app/lifecircle-tradecore.jar <strong>指定要启动的项目jar包</strong>    
  