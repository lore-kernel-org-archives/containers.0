From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 18/18] [RFC] user-cr: Cleanup __filepos
Date: Tue, 29 Mar 2011 18:00:59 -0700
Message-ID: <20110330010059.GL22601@count0.beaverton.ibm.com>
References: <65466a734e085f916c776de153dfddf1c60aea7b.1300382276.git.matthltc@us.ibm.com>
	<c0d1aeb2aa40cecab3182ce686833b964cd8c07f.1300382276.git.matthltc@us.ibm.com>
	<79950217f2c66153c2b4b5bfb55bd5f1759b7933.1300382276.git.matthltc@us.ibm.com>
	<4e4459e8d18102996eedb18a216b45b93dc473c2.1300382276.git.matthltc@us.ibm.com>
	<27ba6a5c70b7e4e3aba2f42641b322f7a7bef7ba.1300382276.git.matthltc@us.ibm.com>
	<a62f11e2f3c8fb4d1271414b5ae854c29ee73ae8.1300382276.git.matthltc@us.ibm.com>
	<8db3ca5ee994168916fbb8d36a604c06e18e2c7b.1300382276.git.matthltc@us.ibm.com>
	<b2088002d6b93118cfd333c8920a4126b1c9759a.1300382276.git.matthltc@us.ibm.com>
	<57f87d60d23843cd67929c96d42b238a47b3fd9a.1300382276.git.matthltc@us.ibm.com>
	<4D90D22A.5090301@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D90D22A.5090301-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Mar 28, 2011 at 02:23:38PM -0400, Oren Laadan wrote:
> 
> 
> On 03/17/2011 01:27 PM, Matt Helsley wrote:
> > Based on the original commit it's unclear why we didn't go with the far
> > simpler approach of using the lseek() system call (or suitably-sized variant)
> > to determine the position in the stream where the object was found. This
> 
> ... because it may be an arbitrary stream, including pipe/socket which
> do not support lseek() operation.

Ahh, true. Thanks for picking up the rest.

Cheers,
	-Matt Helsley
