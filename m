From: Nicolas Bourbaki <ncl.bourbaki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: PROBLEM: LXC Container, CIFS and Kerberos isolation issue
Date: Fri, 4 Feb 2011 09:37:26 +0100
Message-ID: <AANLkTi=Napxox2UKCfeBD2OYs+7GS__CQKgcfop5FEet@mail.gmail.com>
References: <AANLkTin8r7j2XYG5JvsAd7KVcGAW0SwW3yhQfa0LeJXa@mail.gmail.com>
	<4D4AE99B.8030500@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D4AE99B.8030500-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

2011/2/3 Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>:
> cc:ing the containers list for tracking purposes...
>

I've created an entry in the  kernel.org' bugzilla #28122 (I forget
that this may have been the proper way to do it). Seem's it more
global than I first thank.

>> ------------------------------------------------------------------------=
-----------------------------------------------------
>> [1.] Summary
>> Kerberos credential are taken from the host context when using
>> mount.cifs in an lxc container
>
> Yeah, not surprised there's more to do there. =A0I only had one very
> simple test case, and I stopped when I made that work.
>
> I'm happy to fix it, the question is how do I set up a kerberos
> authentication test case? =A0(I'm not very experienced at setting up
> samba, I'm more a developer than a sysadmin.) =A0A quick rummage found:
>
> =A0https://help.ubuntu.com/community/Samba/Kerberos
>
> Which presumably explains it. =A0I'll go read that...

If you have any question in setting it, I may try to help, giving you
some of our configuration.

Thanks

Nicolas
