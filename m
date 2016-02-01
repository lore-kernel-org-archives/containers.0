From: pravin shelar <pshelar-LZ6Gd1LRuIk@public.gmane.org>
Subject: Re: [PATCH] openvswitch: allow management from inside user namespaces
Date: Mon, 1 Feb 2016 12:50:26 -0800
Message-ID: <CAOrHB_DAtYm-s5Lc-EpSAxXDZHPzgXzcyZhwiYtg=zT=LTrgWg__22195.2848638923$1454360638$gmane$org@mail.gmail.com>
References: <1454072433-20137-1-git-send-email-tycho.andersen@canonical.com>
	<8760yccvbw.fsf@x220.int.ebiederm.org>
	<20160129163744.GA3558@hopstrocity>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160129163744.GA3558@hopstrocity>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Justin Pettit <jpettit-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jan 29, 2016 at 8:37 AM, Tycho Andersen
<tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> Hi Eric,
>
> Thanks for the review.
>
> On Fri, Jan 29, 2016 at 08:29:55AM -0600, Eric W. Biederman wrote:
>> Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:
>>
>> > Operations with the GENL_ADMIN_PERM flag fail permissions checks because
>> > this flag means we call netlink_capable, which uses the init user ns.
>> >
>> > Instead, let's do permissions checks in each function, but use the netlink
>> > socket's user ns instead of the initial one, to allow management of
>> > openvswitch resources from inside a user ns.
>> >
>> > The motivation for this is to be able to run openvswitch in unprivileged
>> > containers. I've tested this and it seems to work, but I really have no
>> > idea about the security consequences of this patch, so thoughts would be
>> > much appreciated.
>>
>> So at a quick look using ns_capable this way is probably buggy.
>>
>> netlink is goofy (because historically we got this wrong), and I forget
>> what the specific rules are.  The general rule is that you need to do
>> your permission checks on open/create/connect and not inside send/write
>> while processing data.  Otherwise there is a class of privileged
>> applications where you can set their stdout to some precreated file
>> descriptor and their output can be made to act as a command, bypassing
>> your permission checks.
>
> It's worth noting that this patch doesn't move the checks (i.e., they
> are still done at write time currently in the kernel), it just relaxes
> them to root in the user ns instead of real root. This means I can
> currently exploit netlink this way as an unprivileged, just not from
> within an unprivileged container.
>
> An alternate version of this patch below might be more favorable, as
> we may want to do something like this elsewhere in netlink. I think it
> also clarifies the situation a bit, at the cost of adding another
> flag.
>
> A third option would be to move this check to connect time, but that
> would force everything in the family (since that's the only thing you
> connect /to/ in netlink) to have the same required permissions, which
> might (probably?) break stuff; e.g. you can call OVS_FLOW_CMD_GET
> without CAP_NET_ADMIN, but if we changed everything in the family to
> require it, that would break.
>
> Tycho
> ---
>  include/uapi/linux/genetlink.h |  1 +
>  net/netlink/genetlink.c        |  6 ++++--
>  net/openvswitch/datapath.c     | 20 ++++++++++----------
>  3 files changed, 15 insertions(+), 12 deletions(-)
>
> diff --git a/include/uapi/linux/genetlink.h b/include/uapi/linux/genetlink.h
> index c3363ba..5512c90 100644
> --- a/include/uapi/linux/genetlink.h
> +++ b/include/uapi/linux/genetlink.h
> @@ -21,6 +21,7 @@ struct genlmsghdr {
>  #define GENL_CMD_CAP_DO                0x02
>  #define GENL_CMD_CAP_DUMP      0x04
>  #define GENL_CMD_CAP_HASPOL    0x08
> +#define GENL_UNS_ADMIN_PERM    0x10
>
This approach looks good to me.
