From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 1/5] The config option itself
Date: Wed, 26 Sep 2007 09:30:28 -0700
Message-ID: <20070926093028.c3a57137.randy.dunlap@oracle.com>
References: <46FA7D4D.8040808@openvz.org>
	<46FA7E20.80207@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756780AbXIZQcU@vger.kernel.org>
In-Reply-To: <46FA7E20.80207@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Andrew Morton <akpm@osdl.org>, Serge Hallyn <serue@us.ibm.com>, Cedric Le Goater <clg@fr.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

On Wed, 26 Sep 2007 19:43:28 +0400 Pavel Emelyanov wrote:

> The option is called NAMESPACES. It can be selectable only
> if EMBEDDED is chosen (this was Eric's requisition). When
> the EMBEDDED is off namespaces will be on automatically.

and when EMBEDDED is on, namespaces will be off automatically,
until it is enabled?  Is that what you want?  (It's OK by me.)

Same way for NAMESPACES_EXPERIMENTAL.

> One more option (NAMESPACES_EXPERIMENTAL) was added by 
> Serge's request to move there all the namespaces that are 
> not finished yet. Currently only the user and the network
> namespaces are such.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> ---
> 
> diff --git a/init/Kconfig b/init/Kconfig
> index 684ccfb..05a71d7 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -369,6 +360,23 @@ config RELAY
>  
>  	  If unsure, say N.
>  
> +config NAMESPACES
> +	bool "The namespaces support" if EMBEDDED

	bool "Namespaces support" if EMBEDDED

> +	default !EMBEDDED
> +	help
> +	  Provides the way to make tasks work with different objects using
> +	  the same id. For example same IPC id may refer to different objects
> +	  or same user id or pid may refer to different tasks when used in
> +	  different namespaces.
> +
> +config NAMESPACES_EXPERIMENTAL
> +	bool "Add the experimantal namespaces support" if EMBEDDED

	              experimental

> +	depends on NAMESPACES && EXPERIMENTAL
> +	default !EMBEDDED
> +	help
> +	  Also include the support for the namespaces that are not fnished
> +	  or well developed yet
> +
>  config BLK_DEV_INITRD
>  	bool "Initial RAM filesystem and RAM disk (initramfs/initrd) support"
>  	depends on BROKEN || !FRV
> -


---
~Randy
Phaedrus says that Quality is about caring.
