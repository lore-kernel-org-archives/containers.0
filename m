From: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: PROBLEM: LXC Container, CIFS and Kerberos isolation issue
Date: Fri, 4 Feb 2011 14:36:20 -0600
Message-ID: <4D4C6344.6020704@parallels.com>
References: <AANLkTin8r7j2XYG5JvsAd7KVcGAW0SwW3yhQfa0LeJXa@mail.gmail.com>	<4D4AE99B.8030500@parallels.com>
	<AANLkTi=Napxox2UKCfeBD2OYs+7GS__CQKgcfop5FEet@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTi=Napxox2UKCfeBD2OYs+7GS__CQKgcfop5FEet-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nicolas Bourbaki <ncl.bourbaki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 02/04/2011 02:37 AM, Nicolas Bourbaki wrote:
> 2011/2/3 Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>:
>> cc:ing the containers list for tracking purposes...
>>
> 
> I've created an entry in the  kernel.org' bugzilla #28122 (I forget
> that this may have been the proper way to do it). Seem's it more
> global than I first thank.

It's nice for tracking purposes, but if you'd put a bug report in there
and hadn't cc'd me, I'd never have seen it.

>>  https://help.ubuntu.com/community/Samba/Kerberos
>>
>> Which presumably explains it.  I'll go read that...
> 
> If you have any question in setting it, I may try to help, giving you
> some of our configuration.

Well, it's not quite trivial to set up:

https://help.ubuntu.com/community/Kerberos

> All servers that are part of a Kerberos authentication realm should
> be assigned a Fully Qualified Domain Name (FQDN) that is both
> forward- and reverse-resolvable.

But apparently I can fake that with /etc/hosts...

I note that installing "krb5-kdc krb5-admin-server" installed bind 9, an
SGML library, and a geoip database.  And failed to download 11 packages
until I ran "aptitude update" on the lenny test environment.

Setting up krb5-kdc (1.8.3+dfsg-4) ...
krb5kdc: cannot initialize realm KVM - see log file for details
Setting up krb5-admin-server (1.8.3+dfsg-4) ...
kadmind: No such file or directory while initializing, aborting

Yeah, this is probably going to take a while...

Rob
