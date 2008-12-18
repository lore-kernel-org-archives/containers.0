From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/3] keys: play nicely with user namespaces
Date: Thu, 18 Dec 2008 11:46:13 -0600
Message-ID: <20081218174613.GA13968@us.ibm.com>
References: <20081217235536.GA932@us.ibm.com>
	<20081212141707.GB9571@us.ibm.com>
	<20081211232323.GA8343@us.ibm.com> <3507.1229086294@redhat.com>
	<25987.1229097458@redhat.com> <3547.1229607983@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <3547.1229607983-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting David Howells (dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> 
> Try:
> 
> 	http://people.redhat.com/~dhowells/keys/keyutils/keyutils-tests.tar.bz2
> 
> There were three updates required:
> 
>  (1) chown is now supported.
> 
>  (2) keyctl unlink does old keyring pointer block destruction lazily, and so a
>      wait is required for the key being unlinked to be destroyed.
> 
>  (3) Anonymous session keyrings are now called "_ses" rather than "_ses.<pid>".
> 
> I've also made the following changes:
> 
>  (4) The name of the output file for each test is printed:
> 
> 	=== /mnt/testarea/tmp.y9MVa88S ===
> 
>  (5) If a failure occurs, 'keyctl show' is dumped into the output file.

Cool, thanks.  I needed the following change to toolbox.inc.sh.orig in
order to be able to run with >1 user namespaces:

36c36
< maxsquota=`grep '^ *0': /proc/key-users | sed s@.*/@@`
---
> maxsquota=`grep '^ *0': /proc/key-users | sed s@.*/@@ | head -1`

since /proc/key-users then lists multiple entries.  Otherwise,
all tests pass when running the testsuite in a child-user-ns.

So I'll just sit on these patches waiting for an acked-by (or nack),
then ask for these three patches in linux-next.

thanks,
-serge
