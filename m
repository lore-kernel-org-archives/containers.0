From: Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>
Subject: Re: Kernel text size with pid namespace
Date: Fri, 21 Sep 2007 10:15:55 -0500
Message-ID: <20070921151554.GV4219@waste.org>
References: <20070920001644.GA14880@us.ibm.com>
	<20070920033945.GM4219@waste.org>
	<20070921050359.GA1416@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070921050359.GA1416-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Sep 20, 2007 at 10:03:59PM -0700, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> Matt Mackall [mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org] wrote:
> | On Wed, Sep 19, 2007 at 05:16:44PM -0700, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> | > Matt,
> | > 
> | > The pid-namespace patcheset (http://lkml.org/lkml/2007/8/10/118)
> | > was added to the -mm tree in 2.6.23-rc3-mm1.
> | > 
> | > With CONFIG_CC_OPTIMIZE_FOR_SIZE=y this patchset increases the kernel
> | > text size by about 5K (closer to 6K when the config token is set to N).
> | 
> | That's not too bad.
> 
> Ok, thanks, I won't worry about for now :-)
> 
> Just curious, is there a magic number like 8K or 32K increase in size (of
> unconditional code) that one should watch out for ?

All size increase is a step backward for folks who already have a
working kernel. There are today more than a million cellphones running
Linux where the number one priority is reducing footprint. PID
namespaces are quite low on their wishlist. So as long as the feature
is non-optional, you've got a fairly heavy burden to make it as small
as possible. Especially as this is just the first part of several
namespace pieces.

-- 
Mathematics is the supreme nostalgia of our time.
