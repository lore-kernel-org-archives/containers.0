From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v3] scsi: require CAP_SYS_ADMIN to write to procfs
	interface
Date: Thu, 09 Nov 2017 15:40:18 -0600
Message-ID: <87inejdtbx.fsf__31650.8846976378$1510263643$gmane$org@xmission.com>
References: <20171105025635.10843-1-asarai@suse.de>
	<b3bcff37-d77d-4dc6-ba83-7dddcb51a703@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <b3bcff37-d77d-4dc6-ba83-7dddcb51a703-l3A5Bk7waGM@public.gmane.org> (Aleksa Sarai's
	message of "Sun, 5 Nov 2017 15:02:10 +1100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Cc: "Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cyphar-gVpy/LI/lHzQT0dZR+AlfA@public.gmane.org, "James E.J. Bottomley" <jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org> writes:

> On 11/05/2017 01:56 PM, Aleksa Sarai wrote:
>> Previously, the only capability effectively required to operate on the
>> /proc/scsi interface was CAP_DAC_OVERRIDE (or for some other files,
>> having an fsuid of GLOBAL_ROOT_UID was enough). This means that
>> semi-privileged processes could interfere with core components of a
>> system (such as causing a DoS by removing the underlying SCSI device of
>> the host's / mount).
>
> An alternative to this patch would be to make the open(2) call fail, if you try
> to open it write-only or read-write. Not sure which would be preferred (should
> it be possible to pass /proc/scsi/scsi to a semi-privileged process to write
> to?).

Making open fail is very much the preferred solution.

Testing for permission on write can be avoided by finding a suid root
application whose error output acts like a suid cat.

The best current practice for adding this kind of permission check is to
add the check in open.  For some older use cases where we made this
mistake we had to maintian a check during write to avoid breaking
userspace.  But as this check is new there is no reason to add a check
anywhere except in open.

Eric
