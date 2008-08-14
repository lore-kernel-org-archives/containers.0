From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Devel] Re: [RFC][PATCH 1/4] checkpoint-restart:
	general	infrastructure
Date: Thu, 14 Aug 2008 08:16:17 -0700
Message-ID: <1218726977.23641.6.camel__33709.5530624085$1218727125$gmane$org@nimitz>
References: <20080807224033.FFB3A2C1@kernel>
	<20080807224034.735B1F84@kernel>	<200808081146.54834.arnd@arndb.de>
	<1218221451.19082.36.camel@nimitz> <489CB3CA.6050304@cs.columbia.edu>
	<48A3E81C.6010008@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48A3E81C.6010008-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2008-08-14 at 12:09 +0400, Pavel Emelyanov wrote:
> E.g. consider we are saving a container image on ipv6 node and trying 
> to restore from it on the one without the ipv6. In that case we *may*
> have some object of for example CKPT_IPV6_IFA type of CLPT_IPV6_SOCK_INFO
> and fail the restoration process when finding such in an input file. But 
> what we should *not* do is to write any information about whether we had
> the CONFIG_IPV6 turned on on the dumping side and check for this on the
> restoring side.

The only problem I can see with this is that you lose efficiency,
especially when you have to build your checkpoint image with lots of
things that are config-specific.

The approach sounds like a good one in theory, but I'm a bit skeptical
that we could stick to it in practice, in a mainline kernel where there
are billions of config options.  It is definitely something to strive
for, though.  Good point!

-- Dave
