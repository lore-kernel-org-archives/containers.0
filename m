From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: Question for remount
Date: Tue, 24 Feb 2009 09:33:38 +0800
Message-ID: <49A34E72.1040609__9701.32297738946$1235439332$gmane$org@cn.fujitsu.com>
References: <20090220190223.e8b4f6a8.kamezawa.hiroyu@jp.fujitsu.com>	<6599ad830902200822u6d453340me718bacac3925040@mail.gmail.com>	<d7928a87d8c1bf661e3a3b64db9fa988.squirrel@webmail-b.css.fujitsu.com>	<49A20ACE.7020309@cn.fujitsu.com>
	<20090224085724.4cc1b3b2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090224085724.4cc1b3b2.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

KAMEZAWA Hiroyuki wrote:
> On Mon, 23 Feb 2009 10:32:46 +0800
> Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> 
>> KAMEZAWA Hiroyuki wrote:
>>> Paul Menage さんは書きました：
>>>> On Fri, Feb 20, 2009 at 2:02 AM, KAMEZAWA Hiroyuki
>>>> <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
>>>>> 2. /proc/mounts information of release_agent should be updated....
>>>>>   when it's overwritten directly.
>>>> Yes, definitely. But shouldn't that happen already?
>>>> cgroup_show_options() reports the current value of
>>>> root->release_agent_path in /proc/mounts. Is it possible that mount is
>>>> actually storing/retrieving this information in /etc/mtab, which
>>>> doesn't get updated?
>>>>
>>> Ah, you're right. /proc/mounts is updated but /etc/mtab is not updated.
>>> Hmm..from man mount(1), /etc/mtab is not synchronized with /proc/mounts.
>>> Do we need to allow release_agent override at remount ?
>>>
>> Since we've allowed this behavior, I think we shouldn't disallow it to
>> supprise users?
>>
> In a bit different stroy, it already surprises a user (me).
> for example)
> 

I think what may surprise people is the following mount will append opts
to the original opts.

> #mount -t cgroup none /cgroups -ocpu,release_agent=hogehoge
> #mount -oremount,cpuacct /cgroups,release_agent=xxxx
> => remount fails. because the option "release_agent" appears twice.
> 
> #mount -t cgroup none /cgroups -ocpu,release_agent=hogehoge
> #mount -t cgroup none /cgroups -oremount,cpuacct /cgroups,release_agent=xxxx
> => remount success.
> 
> At least, updating documentation to notice this is necessary I think.
> 

How about this:

[PATCH] cgroups: more documentation for remount and release_agent

This won't remove cpuacct from the mounted hierachy:
 # mount -t cgroup -o cpu,cpuacct xxx /mnt
 # mount -o remount,cpu /mnt

Because for this usage mount(8) will append the new options to the original
options.

And this will get you right:
 # mount [-t cgroup] -o remount,cpu xxx /mnt

Also document how to specify and change release_agent.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 93feb84..824277d 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -337,8 +337,19 @@ subsystems, type:
 
 To change the set of subsystems bound to a mounted hierarchy, just
 remount with different options:
+# mount -o remount,cpuset,ns hier1 /dev/cgroup
 
-# mount -o remount,cpuset,ns  /dev/cgroup
+Now numtasks is removed from the hierarchy and ns is added.
+
+Note this will add ns to the hierarchy but won't remove numtasks or
+cpuset:
+# mount -o remount,ns /dev/cgroup
+
+To Specify a hierarchy's release_agent:
+# mount -t cgroup -o cpuset,release_agent="/sbin/cpuset_release_agent" \
+  xxx /dev/cgroup
+
+Note that specifying 'release_agent' more than once will return failure.
 
 Note that changing the set of subsystems is currently only supported
 when the hierarchy consists of a single (root) cgroup. Supporting
@@ -349,6 +360,11 @@ Then under /dev/cgroup you can find a tree that corresponds to the
 tree of the cgroups in the system. For instance, /dev/cgroup
 is the cgroup that holds the whole system.
 
+If you want to change the value of release_agent:
+# echo "/sbin/new_release_agent" > /dev/cgroup/release_agent
+
+It can also be changed via remount.
+
 If you want to create a new cgroup under /dev/cgroup:
 # cd /dev/cgroup
 # mkdir my_cgroup
