From: Andreas B Aaen <andreas.aaen-546VmZ+UeKYX2WXlbB3fKg@public.gmane.org>
Subject: Re: [PATCH 06/11] sysfs: Implement sysfs tagged directory support.
Date: Wed, 2 Jul 2008 09:18:53 +0200
Message-ID: <200807020918.53142.andreas.aaen@tietoenator.com>
References: <20080618170729.808539948@theryb.frec.bull.fr>
	<m1ej6d9c2r.fsf@frodo.ebiederm.org> <486B060C.7030607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <486B060C.7030607-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wednesday 02 July 2008 06:37, Tejun Heo wrote:
> I was imagining something like...
>
> 	mount -t sysfs -o ns=0,4,5 /my/sys
>
> And let the userland control which ns's are visible in the particular
> mount.  I'm not sure how useful that will be tho.

Useful. However I didn't know that an indexnumber was associated with the 
network namespaces.

Especially if you want to use network namespaces for scaleability and not 
isolation purposes.

Regards,
-- 
Andreas Bach Aaen              System Developer, M. Sc. 
Tieto Enator A/S               tel: +45 89 38 51 00
Skanderborgvej 232             fax: +45 89 38 51 01
8260 Viby J      Denmark       andreas.aaen-546VmZ+UeKYX2WXlbB3fKg@public.gmane.org
