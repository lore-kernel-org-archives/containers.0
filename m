From: Gabor Gombas <gombasg-SuEj7oiQppWHXe+LvDLADg@public.gmane.org>
Subject: Re: [RFC] Mount point suggestions for cgroup
Date: Thu, 5 Nov 2009 09:26:12 +0100
Message-ID: <20091105082612.GE24467__13287.6313561157$1257409612$gmane$org@boogie.lpds.sztaki.hu>
References: <20091104063005.GC3560@balbir.in.ibm.com>
	<20091104154024.0b8f6123.kamezawa.hiroyu@jp.fujitsu.com>
	<20091104081618.GD3560@balbir.in.ibm.com>
	<1257348117.31972.4360.camel@nimitz>
	<20091104161142.GA8825@us.ibm.com> <4AF1AACE.6060705@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AF1AACE.6060705-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jan Safranek <jsafrane-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Bharata B Rao <bharata.rao-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, libcg-devel <libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, "menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Nov 04, 2009 at 05:24:46PM +0100, Jan Safranek wrote:

> LSB (and FHS) IMHO does not specify any place for such stuff:
> 
> /dev - for devices only, cgroups are not devices

The FHS says the following for /dev on Linux:

	/dev : Devices and special files

IMHO cgroups are covered by "special files".

Gabor

-- 
     ---------------------------------------------------------
     MTA SZTAKI Computer and Automation Research Institute
                Hungarian Academy of Sciences
     ---------------------------------------------------------
