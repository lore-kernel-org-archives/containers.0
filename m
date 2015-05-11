From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [stable] Locked mount and loopback mount fixes
Date: Mon, 11 May 2015 08:55:46 -0500
Message-ID: <87egmnrzfh.fsf@x220.int.ebiederm.org>
References: <1431280791.2233.50.camel@decadent.org.uk>
	<AD3FF3AE-4EC2-4239-97C6-96A1818E8856@xmission.com>
	<20150511111901.GD16635@ares.olymp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150511111901.GD16635-YD9HeJR0N8hLdv8CNEAgDg@public.gmane.org> (Luis Henriques's message of
	"Mon, 11 May 2015 12:19:01 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Luis Henriques <luis.henriques-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>, stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Luis Henriques <luis.henriques-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:

> On Sun, May 10, 2015 at 09:23:01PM -0500, Eric W. Biederman wrote:
>> 
>> 
>> On May 10, 2015 12:59:51 PM CDT, Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org> wrote:
>> >Why were these not cc'd to stable?  Was this an oversight, or are they
>> >simply not needed for fixing any known bugs?
>> 
>> An oversight.
>> 
>> On their own they don't matter but other patches cc'd to stable do depend on them for correct operation.
>> 
>> The fact most of these changes depends on fs_pin likely limits how far they may be bsckported.
>> 
>> >commit cd4a40174b71acd021877341684d8bb1dc8ea4ae
>> >Author: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> >Date:   Wed Jan 7 14:28:26 2015 -0600
>> >
>> >    mnt: Fail collect_mounts when applied to unmounted mounts
>> >
>
> Thanks, I'm queuing this one for the 3.16 kernel (the 2nd commit
> doesn't seem to be applicable to his kernel).

Yes.  This one isn't harmful back at 3.16.

Without the changes to keep mounts bound together until mntput time it
is not particularly useful.  Keeping mounts bound together until mntput
time depends on the fs_pin infrastructure.  Keeping mounts bound
together until mntput time is what allows fixing things so that users
may not abuse umount -l or unmount on mountpoint removal (unlink/rmdir)
to split mounts appart and see under existing mounts.

Usually seeing what is under existing mounts is generally a don't care
as it is typically just an empty directory.  Sometimes things are
mounted over deliberately, such as /proc/kcore and docker, in which case
it becomes unfortunate if unprivileged users can get under those mounts.

I hope that puts things in perspective.

Eric
