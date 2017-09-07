package eu.biggis.sparkexample;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import scala.Tuple2;

import java.util.Arrays;

/**
 * Created by patrickwiener on 19.07.17.
 */
public class WordCount {

    public static void main (String [] args ){

        SparkConf conf = new SparkConf()
                .setAppName(WordCount.class.getName())
                .setMaster("spark://spark-master:7077");
        JavaSparkContext sc = new JavaSparkContext(conf);

        String input = args[0];
        String output = args[1];

        JavaRDD<String> textFile = sc.textFile(input);
        JavaPairRDD<String, Integer> counts = textFile
                .flatMap(s -> Arrays.asList(s.split(" ")).iterator())
                .mapToPair(word -> new Tuple2<>(word, 1))
                .reduceByKey((a,b) -> a + b);

        counts.saveAsTextFile(output);

    }
}
