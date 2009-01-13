From: chris-SqNQQPNds68nxqbYAscKCQ@public.gmane.org
Subject: Re: Net containers config and usage
Date: Tue, 13 Jan 2009 11:49:24 -0800
Message-ID: <20090113194924.GA24491@versecorp.net>
References: <20090112223545.GA15781@versecorp.net>
	<20090112225140.GA29834@us.ibm.com>
	<20090113005436.GA26167@versecorp.net> <496C4EB0.30203@free.fr>
	<20090113142925.GA11767@us.ibm.com>
	<20090113191837.GA29900@versecorp.net>
	<1231875468.6398.70.camel@groeck-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1231875468.6398.70.camel@groeck-laptop>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Guenter Roeck <groeck-gvzKVTG1yJJBDgjK7y7TUQ@public.gmane.org>
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Jan 13, 2009 at 11:37:48AM -0800, Guenter Roeck wrote:
> Works for me in 2.6.27. 
> Did you enable network namespace support in the kernel ?
> 
> Guenter

Yes, and I'm able to do an "lxc-unshare -n /bin/tcsh", so I guess that's
proof that network namespace support is there in the kernel.  But then when
I go to re-assign an interface, I get the error.

Chris
