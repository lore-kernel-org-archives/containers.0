From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [PATCH 2/5] Move the UTS namespace under the option
Date: Wed, 31 Oct 2007 13:58:45 +0100
Message-ID: <47287C05.5060903@fr.ibm.com>
References: <47285FEE.9030001@openvz.org> <472861D3.4060303@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759260AbXJaM66@vger.kernel.org>
In-Reply-To: <472861D3.4060303@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Andrew Morton <akpm@osdl.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Serge Hallyn <serue@us.ibm.com>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org


> diff --git a/init/Kconfig b/init/Kconfig
> index fc76773..d592aa2 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -409,6 +409,13 @@ config NAMESPACES
>  	  or same user id or pid may refer to different tasks when used in
>  	  different namespaces.
> 
> +config UTS_NS
> +	bool "UTS namespace"
> +	depends on NAMESPACES

should we add a 'default y' like in 2.6.23 ?

C.
