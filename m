From: Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>
Subject: Re: question about default values for per-namespace settings
Date: Mon, 19 May 2014 21:30:25 +0200
Message-ID: <537A5BD1.90906__31257.2991046638$1400528144$gmane$org@pandora.be>
References: <20140512140706.GA22082@macbook.localnet>
	<cover.1399909529.git.vvs@openvz.org>
	<5370F781.7010909@parallels.com> <53711B21.1060309@pandora.be>
	<53712B0A.7060007@parallels.com> <53727246.4050306@pandora.be>
	<53748280.60906@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <53748280.60906-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vasily Averin <vvs-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

Vasily Averin schreef op 15/05/2014 11:01:
> Dear Tejun,
>
> how do you think, which defaults should be used for per-namespace settings in general case
> and for per-netns sysctls especially? Do we have some common position about this or
> perhaps we already have some setting that allows to select desired behavior?
>
> I'm preparing patch that makes per-netns sysctls in br_netfilter,
> to be able to enable/disable br-nf-call processing in each network namespace independently.
>
> I've initialized sysctl values in each netns by system defaults, like it was done in similar cases.
> However Bart pointed that "this does introduce a bit of backwards incompatibility":
> currently all netns shares the br_netfilter sysctl settings applied in init_net.
>
>>From OpenVz point of view containers should be properly isolated,
> should have predictable initial configuration
> and should not depend on settings applied in another containers.
> On the other hand independent containers is only one of possible usecases,
> and I have no strong objections against Bart's proposal. Frankly speaking
> initially I've planned to copy setting from init_net too.

You misread my mail. I stated that I'm ok with always starting from the 
defaults (as your patch does). As pointed out by Maciej, always starting 
from init_net isn't really an option in case of nested namespaces (start 
from the parent's namespace instead).
There'll always be pros and cons to whatever you choose here. Complete 
backwards compatibility isn't possible either way.
The only way to keep backwards compatibility is to introduce new proc 
file names and keep the old behavior for the old names (but I'm not in 
favor of that).

cheers,
Bart
