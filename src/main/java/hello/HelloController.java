package hello;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.concurrent.CompletableFuture;
import java.util.HashMap;
import datadog.trace.api.Trace;

@RestController
public class HelloController {
    private final GitHubLookupService gitHubLookupService;

    public HelloController(GitHubLookupService gitHubLookupService) {
        this.gitHubLookupService = gitHubLookupService;
    }

    @RequestMapping("/")
    @Trace
    public String home() {
        this.slow();
        return "Hello!";
    }

    @RequestMapping("/slow")
    @Trace
    public String slow() {
        try {
          Thread.sleep(5000);
        } catch (Exception e) {
          return "Kelnerhax: he ain't sleepy";
        }
        return "Slow!";
    }

    @RequestMapping("/lookup")
    @Trace
    public HashMap<String, String> lookup() throws Exception {
      String user1 = "PivotalSoftware";
      String user2 = "CloudFoundry";
      String user3 = "Spring-Projects";

      // Kick of multiple, asynchronous lookups
      CompletableFuture<User> page1 = gitHubLookupService.findUser(user1);
      CompletableFuture<User> page2 = gitHubLookupService.findUser(user2);
      CompletableFuture<User> page3 = gitHubLookupService.findUser(user3);

      // Wait until they are all done
      CompletableFuture.allOf(page1, page2, page3).join();

      HashMap<String, String> map = new HashMap<>();
      map.put(user1, page1.get().toString());
      map.put(user2, page2.get().toString());
      map.put(user3, page3.get().toString());
      return map;
    }
}
