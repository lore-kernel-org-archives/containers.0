From: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Subject: Re: Kernel 2.6.33-rc6, 3 bugs container specific.
Date: Thu, 04 Feb 2010 17:02:21 +0100
Message-ID: <4B6AEF8D.1050005@free.fr>
References: <1265074676.6260.212.camel@Mercier.safe.ca>	<20100202031647.GA14318@fqdn.org>	<1265121846.6260.231.camel@Mercier.safe.ca>	<4B68649D.2000503@free.fr>
	<20100202181801.GA28412@us.ibm.com>	<1265136215.6260.261.camel@Mercier.safe.ca>	<20100202213254.GH32305@us.ibm.com>
	<4B695535.7020301@free.fr>	<20100203150350.GA7146@us.ibm.com>
	<4B6A9461.1010309@free.fr> <20100204151927.GA7556@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lxc-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20100204151927.GA7556-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/lxc-users>,
	<mailto:lxc-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=lxc-users>
List-Post: <mailto:lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:lxc-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/lxc-users>,
	<mailto:lxc-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: lxc-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

On 02/04/2010 04:19 PM, Serge E. Hallyn wrote:
> I still like your syslog command 11, but assuming we want to keep the
> syslog_ns on nsproxy, I think we really need to stick to clone/unshare.

Yes. let's keep the namespace creation API consistent. this is complex
enough.

C.

------------------------------------------------------------------------------
The Planet: dedicated and managed hosting, cloud storage, colocation
Stay online with enterprise data centers and the best network in the business
Choose flexible plans and management services without long-term contracts
Personal 24x7 support from experience hosting pros just a phone call away.
http://p.sf.net/sfu/theplanet-com
