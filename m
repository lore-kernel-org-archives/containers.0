From: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: PROBLEM: LXC Container, CIFS and Kerberos isolation issue
Date: Thu, 3 Feb 2011 11:44:59 -0600
Message-ID: <4D4AE99B.8030500@parallels.com>
References: <AANLkTin8r7j2XYG5JvsAd7KVcGAW0SwW3yhQfa0LeJXa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTin8r7j2XYG5JvsAd7KVcGAW0SwW3yhQfa0LeJXa-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nicolas Bourbaki <ncl.bourbaki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

cc:ing the containers list for tracking purposes...

On 02/03/2011 07:56 AM, Nicolas Bourbaki wrote:
> Hi,
> 
> I've got a problem with LXC, CIFS and Kerberos. Sorry if you're not
> the person concerned by this but I've seen you submited a patch about
> LXC and CIFS mounts recently
> 
> 
> Here is my bug report :
> 
> 
> -----------------------------------------------------------------------------------------------------------------------------
> [1.] Summary
> Kerberos credential are taken from the host context when using
> mount.cifs in an lxc container

Yeah, not surprised there's more to do there.  I only had one very
simple test case, and I stopped when I made that work.

I'm happy to fix it, the question is how do I set up a kerberos
authentication test case?  (I'm not very experienced at setting up
samba, I'm more a developer than a sysadmin.)  A quick rummage found:

  https://help.ubuntu.com/community/Samba/Kerberos

Which presumably explains it.  I'll go read that...

> [2.] Description
> When using kerberos as system authentication for CIFS, mount fails in
> an LXC container. We need to have the kerberos ticket ans keyutils in
> the host to have it works. So it seem's that there is an isolation
> problem for this particular configuration.
> 
> [2.1] Scenario 1: Host is minimalist, container fully configured
> (kerberos, CIFS, credentials, ...)
> #mount.cifs '//some-server/some-directory' /mnt -o
> iocharset=utf8,rw,sec=krb5i,user=foo
> mount error(2): No such file or directory
> 
> [2.2] Scenario 2: Host has keyutils package (ubuntu) installed but no
> credentials, container fully configured (kerberos, CIFS, credentials,
> ...)
> #mount.cifs '//some-server/some-directory' /mnt -o
> iocharset=utf8,rw,sec=krb5i,user=foo
> mount error(126): Required key not available
>
> [2.3] Scenario 3: Host has keyutils package (ubuntu) installed and
> kerberos credentials, container fully configured (kerberos, CIFS,
> credentials, ...)
> #mount.cifs '//some-server/some-directory' /mnt -o
> iocharset=utf8,rw,sec=krb5i,user=foo
> Succes !

Should be fairly straightforward to fix, I just need to set up the test
case...

> -----------------
> lxc version: 0.7.2
> -----------------
> ii  krb5-config                           2.2
>       Configuration files for Kerberos Version 5
> ii  libgssapi-krb5-2                      1.8.1+dfsg-5ubuntu0.2
>       MIT Kerberos runtime libraries - krb5 GSS-API Mechanism
> ii  libkrb5-26-heimdal                    1.4.0~git20100605.dfsg.1-2
>       Heimdal Kerberos - libraries
> ii  libkrb5-3                             1.8.1+dfsg-5ubuntu0.2
>       MIT Kerberos runtime libraries
> ii  libkrb5support0                       1.8.1+dfsg-5ubuntu0.2
>       MIT Kerberos runtime libraries - Support library
> ii  cifs-utils                            2:4.5-2
>       Common Internet File System utilities

Ok.

Thanks,

Rob
