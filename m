From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next] [RFC] netns: enable cross-ve Unix sockets
Date: Wed, 01 Oct 2008 18:15:26 +0200
Message-ID: <48E3A21E.3060504__30161.8839767345$1222878170$gmane$org@fr.ibm.com>
References: <1222858454-7843-1-git-send-email-den@openvz.org>
	<48E35B4C.1040303@fr.ibm.com>
	<1222860776.23573.49.camel@iris.sw.ru>
	<48E3653C.1070701@fr.ibm.com>
	<1222862583.23573.54.camel@iris.sw.ru>
	<48E36ABF.8030908@fr.ibm.com> <48E36BFA.3040904@openvz.org>
	<48E36DA0.9080400@fr.ibm.com>
	<1222866717.23573.58.camel@iris.sw.ru> <48E37F1B.20601@fr.ibm.com>
	<1222872885.23573.64.camel@iris.sw.ru>
	<48E394D2.5090709@fr.ibm.com> <48E397C1.6050407@openvz.org>
	<48E3998D.4040709@fr.ibm.com> <48E39A7A.8090800@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48E39A7A.8090800-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, benjamin.thery-6ktuUTfB/bM@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Pavel Emelyanov wrote:
> Daniel Lezcano wrote:
>> Pavel Emelyanov wrote:
>>>> Yes per namespace, I agree.
>>>>
>>>> If the option is controlled by the parent and it is done by sysctl, you 
>>>> will have to make proc/sys per namespace like Pavel did with /proc/net, no ?
>>> /proc/sys is already per namespace actually ;) Or what did you mean by that?
>>
>> Effectively I was not clear :)
>>
>> I meant, you can not access /proc/sys from outside the namespace like 
>> /proc/net which can be followed up by /proc/<pid>/net outside the namespace.
> 
> Ah! I've got it. Well, I think after Al Viro finishes with sysctl
> rework this possibility will appear, but Denis actually persuaded me
> in his POV - if we do want to disable shared sockets we *can* do this
> by putting containers in proper mount namespaces of chroot environments.

And I agree with this point. But :)

  1 - the current behaviour is full isolation. Shall we/can we change 
that without taking into account there are perhaps some people using 
this today ? I don't know.

  2 - I wish to launch a non chrooted application inside a namespace, 
sharing the file system without sharing the af_unix sockets, because I 
don't want the application running inside the container overlap with the 
socket af_unix of another container. I prefer to detect a collision with 
a strong isolation and handle it manually (remount some part of the fs 
for example).

  3 - I would like to be able to reduce this isolation (your point) to 
share the af_unix socket for example to use /dev/klog or something else.

I don't know how much we can consider the point 1, 2 pertinent, but 
disabling 3 lines of code via a sysctl with strong isolation as default 
and having a process unsharing the namespace in userspace and changing 
this value to less isolation is not a big challenge IMHO :)
