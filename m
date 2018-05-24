From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 2/6] vfs: Allow userns root to call mknod on owned
	filesystems.
Date: Thu, 24 May 2018 11:55:45 -0500
Message-ID: <87y3g92dta.fsf__2815.63343382931$1527181158$gmane$org@xmission.com>
References: <87o9h6554f.fsf@xmission.com>
	<20180523232538.4880-2-ebiederm@xmission.com>
	<20180524135517.GQ3401@ubuntu-xps13>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180524135517.GQ3401@ubuntu-xps13> (Seth Forshee's message of
	"Thu, 24 May 2018 08:55:17 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christian Brauner <christian-STijNZzMWpgWenYVfaLwtA@public.gmane.org>
List-Id: containers.vger.kernel.org

Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:

> On Wed, May 23, 2018 at 06:25:34PM -0500, Eric W. Biederman wrote:
>> These filesystems already always set SB_I_NODEV so mknod will not be
>> useful for gaining control of any devices no matter their permissions.
>> This will allow overlayfs and applications to fakeroot to use device
>> nodes to represent things on disk.
>> 
>> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>
> For a normal filesystem this does seem safe enough.
>
> However, I'd also like to see us allow unprivileged mounting for
> overlayfs, and there we need to worry about whether this would allow a
> mknod in an underlying filesystem which should not be allowed. That
> mknod will be subject to this same check in the underlying filesystem
> using the credentials of the user that mounted the overaly fs, which
> should be sufficient to ensure that the mknod is permitted.

Sufficient to ensure the mknod is not permitted on the underlying
filesystem.  I believe you mean.

> Thus this looks okay to me.
>
> Acked-by: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

Eric
