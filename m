From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [GIT PULL] user namespace and namespace infrastructure changes
	for 3.8
Date: Thu, 20 Dec 2012 23:47:22 -0800
Message-ID: <87k3sbonhx.fsf@xmission.com>
References: <1356073548.24099.26@driftwood>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1356073548.24099.26@driftwood> (Rob Landley's message of "Fri,
	21 Dec 2012 01:05:48 -0600")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org> writes:

> On 12/17/2012 05:18:57 PM, Eric W. Biederman wrote:
>> Work remains to make it safe to build user namespaces and 9p, afs,
>> ceph, cifs, coda, gfs2, ncpfs, nfs, nfsd, ocfs2, and xfs so the  
>> Kconfig
>> guard remains in place preventing that user namespaces from being  
>> built
>> when any of those filesystems are enabled.
>
> What work specifically?

Essentially the uid_t to kuid_t and gid_t to kgid_t conversion.

These are the more complex filesystems.  And I haven't yet had
the time to go through the preliminary patches in my development branch
and convert them into stupid obviously correct patches, or review them
closely.

The changes generally are pretty simple the amount of review to ensure I
didn't overlook things tends to proprotional to the size of the file
system.

There is also the fact that I don't use most of those file-systems.

The big advantage of finishing those filesystems is that user namespaces
can be turned on in allyesconfig, allowing my compile time checks to
notice when someone doesn't use kuids and kgids.

Eric
