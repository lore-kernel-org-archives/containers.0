From: Raghavendra KT <raghavendra.kt-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 12/12] cgroup: implement dynamic subtree controller
	enable/disable on the default hierarchy
Date: Thu, 17 Apr 2014 23:33:50 +0530
Message-ID: <CAC4Lta0tD=FbtVpGnLw2sKMY69+AnqYqaOvCQdFs88JeR5Pemw__28345.038687303$1397757843$gmane$org@mail.gmail.com>
References: <1397511430-2673-1-git-send-email-tj@kernel.org>
	<1397511430-2673-13-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1397511430-2673-13-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Apr 15, 2014 at 3:07 AM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
[...]
> * White-space separated list of controller names prefixed with either
>   '+' or '-' can be written to "cgroup.subtree_control".  The ones
>   prefixed with '+' are enabled on the controller and '-' disabled.
>

[...]

> +
> +/* change the enabled child controllers for a cgroup in the default hierarchy */
> +static int cgroup_subtree_control_write(struct cgroup_subsys_state *dummy_css,
> +                                       struct cftype *cft, char *buffer)
> +{
> +       unsigned long enable_req = 0, disable_req = 0, enable, disable;
> +       struct cgroup *cgrp = dummy_css->cgroup, *child;
> +       struct cgroup_subsys *ss;
> +       char *tok, *p;
> +       int ssid, ret;
> +
> +       /*
> +        * Parse input - white space separated list of subsystem names
> +        * prefixed with either + or -.
> +        */
> +       p = buffer;
> +       while ((tok = strsep(&p, " \t\n"))) {
> +               for_each_subsys(ss, ssid) {
> +                       if (ss->disabled || strcmp(tok + 1, ss->name))
> +                               continue;
> +
> +                       if (*tok == '+') {
> +                               enable_req |= 1 << ssid;
> +                               disable_req &= ~(1 << ssid);
> +                       } else if (*tok == '-') {
> +                               disable_req |= 1 << ssid;
> +                               enable_req &= ~(1 << ssid);
> +                       } else {
> +                               return -EINVAL;
> +                       }
> +                       break;
> +               }
> +               if (ssid == CGROUP_SUBSYS_COUNT)
> +                       return -EINVAL;
> +       }

I undertsand that with the above parsing we could do
echo "-blkio +blkio" > cgroup.subtree_control and honor last enable/disable.
It confused me while testing. do you think we should return -EINVAL in
such case?
