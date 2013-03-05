From: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Subject: Re: cgroup_release_agent() hung task warnings
Date: Tue, 05 Mar 2013 12:28:04 +1100
Message-ID: <87d2ved49n.fsf__40717.021856881$1362526607$gmane$org@rustcorp.com.au>
References: <CA+ydwtrRAf5VW_iZYOjzmTv6Y0ebprXw_RfWVmR1okQOxQx=CA@mail.gmail.com>
	<51340E2E.4070805@huawei.com>
	<20130304173358.GB30413@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130304173358.GB30413-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tommi Rantala <tt.rantala-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> writes:
> (cc'ing Rusty Russell)
>
> On Mon, Mar 04, 2013 at 10:59:58AM +0800, Li Zefan wrote:
>> On 2013/3/3 3:23, Tommi Rantala wrote:
>> > Hello,
>> > 
>> > I'm seeing the following hung task warnings when fuzzing the kernel
>> > with trinity (in a qemu virtual machine, as the root user), that I
>> > have not seen before with 3.8 or earlier. The kernel is
>> > b0af9cd9aab60ceb17d3ebabb9fdf4ff0a99cf50 (Merge tag
>> > 'lzo-update-signature-20130226' of
>> > git://github.com/markus-oberhumer/linux).
>> > 
>> 
>> This doesn't look like a cgroup bug.
>
> Yes, it looks like a problem in usermodehelper.  Rusty, it looks like
> usermodehelper can jam with OOM killer going wild.  Any ideas?  The
> original report is at
>
>   https://lkml.org/lkml/2013/3/2/126

Is it really stuck, or just v. v. slow as it thrashes?

Like Tejun, I can't see how it would really get stuck...

Cheers,
Rusty.
