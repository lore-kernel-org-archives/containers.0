From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH] liblxc: add scripts/lxc-fedora.in (WAS: Re: [PATCH]
	liblxc: Update lxc-debian to use the lenny release)
Date: Sun, 08 Mar 2009 17:34:02 +0100
Message-ID: <49B3F37A.4000502@free.fr>
References: <1233825739.28338.22.camel@localhost>	
	<1233826353.28338.35.camel@localhost> <49906491.8050200@free.fr>	
	<1234213118.29561.17.camel@localhost> <4990A410.3040701@free.fr>	
	<87d4dr41o0.fsf@caffeine.danplanet.com>
	<1234254507.8536.14.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1234254507.8536.14.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Matt Helsley wrote:
> On Mon, 2009-02-09 at 15:43 -0800, Dan Smith wrote:
>   
>> DL> It may be possible to use yum like debootstrap for an minbase
>> DL> fedora install.
>>
>> Yep, something like the following should work:
>>
>>   root=/path/to/tmproot
>>   mkdir -p $root/var/lib/rpm
>>   rpm --root $root --initdb
>>   rpm --root $root -Uvfh --nodeps http://fedora.osuosl.org/linux/releases/10/Fedora/i386/os/Packages/fedora-release-10-1.noarch.rpm
>>   yum --installroot=$root -y groupinstall Base
>>     
>
> Looks familiar! ;) I was intrigued by this idea last weekend so I
> started such a script. However I only tested it as far as creating a
> semi-correct rootfs. With the exception of network configs most of the
> configs are still written as for debian. For example I know the selinux
> policy enforcement settings need to move, the inittab needs to be
> replaced by the proper upstart configs, etc.
>
> Of course it's based heavily on Daniel's excellent lxc-debian script.
>
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>   
Applied.
