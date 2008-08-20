From: "Ranjit Manomohan" <ranjitm-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: Some question about your TC cgroups controller !!
Date: Wed, 20 Aug 2008 10:56:15 -0700
Message-ID: <166fe7950808201056g6bf649a8g4f2c6a30f8742ada__31320.2067664408$1219255127$gmane$org@mail.gmail.com>
References: <79f401c9028e$635a1770$8310fe81@etri.info>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <79f401c9028e$635a1770$8310fe81-tRM8rG9f+DVhl2p70BpVqQ@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Kim, Chei-Yol" <gauri-mINagvnPBMnWF1p7bDn8Kw@public.gmane.org>
Cc: Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, =?EUC-KR?B?sK21v8Dn?= <djkang-mINagvnPBMnWF1p7bDn8Kw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Aug 19, 2008 at 11:31 PM, Kim, Chei-Yol <gauri-mINagvnPBMnWF1p7bDn8Kw@public.gmane.org> wrote:
> Hello !!
> I'm Chei-yol Kim, I work for ETRI(www.etri.re.kr) in Korea.
> I have very interested in cgroup, their controllers and especially network
> controller.
> Before about a week ago, I send below mail to container mailing list.
> If you don't mind, I hope hear your opion about that.
> I  think your TC cgroup idea is very good and efficient way of network
> controller.
> Can I ask your plan of TC cgroup patch? What is the future work of the TC
> cgroup?

If there are no objections to the current implementation, I have the
following set of patches planned:

1) Supporting ingress packet classification based on cgroups
2) Supporting firewall functionality based on this (e.g. drop a packet
at port 80 if not in the right cgroup)

> If you think your patch has a problem, What is it?

As you pointed out the split logic in configuration of this
functionality (partially in cgroups and the rest with the tc tools) is
something that I wanted to avoid. However when you look at the rich
feature set provided by the linux networking stack to support traffic
shaping and firewalls it becomes very tedious to duplicate all
possible configuration options with cgroups. Hence the compromise in
terms of user configuration complexity. We could always come up with
simple utilities or scripts to make this easier if it becomes a
serious concern.

-Thanks,
Ranjit


>
> I'm sorry for many question.
> But If you share your thinking, it'll be great pleasure to me.
>
> I expect your answer and thank for reading this mail.
>
> - Kim, Chei-yol
>
>
>
> -----Original Message-----
> From: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> [mailto:containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org] On Behalf Of Kim,
> Chei-Yol
> Sent: Wednesday, August 13, 2008 6:05 PM
> To: Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> Subject: Opinion about cgroup network controller
>
>
>
> I'm interested in cgroup network controller.
>
>
>
> As I know, currently announced network controllers are two.
>
>
>
> One is Andrea's network throttle and the other is Ranjit's TC(Traffic
> Control) cgroups subsystem(http://lkml.org/lkml/2008/7/22/361).
>
>
>
> Two implementations is totally different each other.
>
>
>
>
>
>
>
> Network throttle is quite same mechanism to io_throttle. so it just can
> limit socket's rate.
>
>
>
> The most important drawback of it is that it can't support work-conserving
> mode.
>
>
>
> If it were capable of work-conserving mode, it could guarantee the minimum
> network rate.
>
>
>
> this point is very important.
>
>
>
>
>
>
>
> The other, ranjit's implementation is to let TC recognize the cgroup so that
> administrator can
>
>
>
> adopt different rate or polish to each cgroups. TC is not easy to use
> without much knowledge.
>
>
>
> Because of the using TC mechanism, user have to configure cgroup and TC
> together. This is not same
>
>
>
> to other controller configuration. Other controllers are controlled by value
> in the cgroup file. But
>
>
>
> ranjit's implementation have to control rate by tc configuration. This
> difference is not good to user.
>
>
>
>
>
>
>
> As the result of this looking, the controller which can resolve these
> problems would be needed now.
>
>
>
> This could support work-conserving mode and easy to use and configured like
> other controllers.
>
>
>
>
>
>
>
> What do you think about this?
>
>
>
>
>
>
>
> I hope many comments.
>
>
>
>
>
>
>
> -       Chei-yol
>
>
>
> _______________________________________________
>
> Containers mailing list
>
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>
> https://lists.linux-foundation.org/mailman/listinfo/containers
>
>
>
>
