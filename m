From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [0/10] User namespaces: introduction
Date: Mon, 25 Aug 2008 14:51:24 -0500
Message-ID: <20080825195124.GA9361@us.ibm.com>
References: <20080822194513.GA10262@us.ibm.com>
	<m1d4k0ixzp.fsf@frodo.ebiederm.org>
	<20080823011731.GA22737@us.ibm.com>
	<m1sksw770k.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1sksw770k.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> 
> > It definately seems to make sense in terms of the security
> > implications.  And solving this before the filesystem handlers seems
> > to make sense too.  Although I would like to get the first 3 patches upstream
> > pretty soon, as I believe they are proper fixes.
> 
> Reasonable.  I'm not certain about free_user continuing to be an inline
> function as it seems a bit non-trivial, but otherwise that sounds correct.

Great, I'll fix that and resend and ask for inclusion.

So based on your input, here is how I'm seeing the next iteration of
usernamespace-filesystem interaction semantics:

if
	0=init_user_ns
	(X,Y) = (userns X, uid Y)
	(0,500) creates (1,0) and (1,1000)
	(1,1000) creates a file /foo/bar
	then
		inode->i_uid = 1000
		inode->i_userns = 1  (we use the mount-provided userns, right?)
			i_userns storing is per-fs, but probably uses xattr)
		the fs stores the fact that (0,500) owns userns 1
			this might be stored just in /etc/userns.conf,
			and parsed at mount time)
	 when (1,1001) looks up /foo/bar, he sees owner=1000
	 when (0,501) looks up /foo/bar, he sees owner=500
	 when (0,501) creates (2,0) and (2,0) looksup /foo/bar,
		he sees owner=0, mode bits clear except the 'other' bits

Put user_ns in struct inode so simple userid mapping can be done
in generic code.

Here is a weirdness:  If (0,500) creates some files as (1,1000)
under /home/hallyn/containers/vs1.  Now the system is rebooted, and the
/etc/userns.conf for some reason is not loaded.  Now when hallyn does
ls /home/hallyn/containers/vs1, he sees files owned by (0,0), with
only the 'other' permissions.  Now he can't make them setuid root so
it's no vulnerability.  Just a wart.

Is that what you had in mind?

But I'll still look at doing capabilities first like you were
saying.

thanks,
-serge
