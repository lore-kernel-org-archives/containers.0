From: atp <Andrew.Phillips-xheW4WVAX9Y@public.gmane.org>
Subject: cpu shielding.
Date: Mon, 06 Feb 2012 13:50:34 +0000
Message-ID: <1328536234.32188.49.camel@foo>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

  Apologies if I'm about to ask a frequently asked question - I did
check back over the last couple of months. 

  Is anyone working on cpu shielding for processes inside a cpu cgroup? 

  We would like to run Java in containers, and unfortunately it likes to
know how many processors there are in the system - to initialise thread
pools and such like. 

  I was thinking along these lines;

--- fs/proc/stat.c.orig	2010-05-21 11:32:32.941258466 +0000
+++ fs/proc/stat.c	2010-05-21 11:40:47.681259133 +0000
@@ -39,7 +39,9 @@
 	getboottime(&boottime);
 	jif = boottime.tv_sec;
 
-	for_each_possible_cpu(i) {
+//	for_each_possible_cpu(i) {
+//	// refer to the visible cpus.
+	for_each_cpu_and(i,cpu_possible_mask,(&current->cpus_allowed)) {
 		user = cputime64_add(user, kstat_cpu(i).cpustat.user);
 		nice = cputime64_add(nice, kstat_cpu(i).cpustat.nice);
 		system = cputime64_add(system, kstat_cpu(i).cpustat.system);
@@ -78,7 +80,10 @@
 		(unsigned long long)cputime64_to_clock_t(steal),
 		(unsigned long long)cputime64_to_clock_t(guest),
 		(unsigned long long)cputime64_to_clock_t(guest_nice));
-	for_each_online_cpu(i) {
+     
+//	for_each_online_cpu(i) {
+//	// cgroup. 
+	for_each_cpu_and(i,cpu_online_mask,(&current->cpus_allowed)) {
 
 		/* Copy values here to work around gcc-2.95.3, gcc-2.96 */
 		user = kstat_cpu(i).cpustat.user;

  I'm sure that there are nicer ways of doing this, but Serge Hallyn
suggested a while ago that I post here. Even though it says 2010, the
patch above looks like it will go against 3.2.4 ok. 
  
  Thanks,
     Andy

-- 
Andrew Phillips
Head of Systems

Direct: +44 (0)203 192 2509
Mobile: +44 (0)7595 242 900

LMAX, Yellow Building, 1A Nicholas Road,  London, W11 4AN



The information in this e-mail and any attachment is confidential and is intended only for the named recipient(s). The e-mail may not be disclosed or used by any person other than the addressee, nor may it be copied in any way. If you are not a named recipient please notify the sender immediately and delete any copies of this message. Any unauthorized copying, disclosure or distribution of the material in this e-mail is strictly forbidden. Any view or opinions presented are solely those of the author and do not necessarily represent those of the company.
