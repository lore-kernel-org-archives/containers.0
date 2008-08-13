From: =?ks_c_5601-1987?B?sejA57+t?= <gauri-mINagvnPBMnWF1p7bDn8Kw@public.gmane.org>
Subject: Opinion about cgroup network controller
Date: Wed, 13 Aug 2008 18:05:25 +0900
Message-ID: <4C86297B4AC6554B8BA018F0806590CE017D543F@email1>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-class: urn:content-classes:message
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

I'm interested in cgroup network controller.

As I know, currently announced network controllers are two.

One is Andrea's network throttle and the other is Ranjit's TC(Traffic Control) cgroups subsystem(http://lkml.org/lkml/2008/7/22/361).

Two implementations is totally different each other.

 

Network throttle is quite same mechanism to io_throttle. so it just can limit socket's rate.

The most important drawback of it is that it can't support work-conserving mode.

If it were capable of work-conserving mode, it could guarantee the minimum network rate.

this point is very important.

 

The other, ranjit's implementation is to let TC recognize the cgroup so that administrator can

adopt different rate or polish to each cgroups. TC is not easy to use without much knowledge.

Because of the using TC mechanism, user have to configure cgroup and TC together. This is not same 

to other controller configuration. Other controllers are controlled by value in the cgroup file. But 

ranjit's implementation have to control rate by tc configuration. This difference is not good to user.

 

As the result of this looking, the controller which can resolve these problems would be needed now.

This could support work-conserving mode and easy to use and configured like other controllers.

 

What do you think about this?

 

I hope many comments.

 

-       Chei-yol
