From: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [PATCH 01/29] task containersv11 basic task container framework
Date: Sun, 30 Sep 2007 02:36:03 -0700
Message-ID: <20070930023603.1f73f5d9.pj@sgi.com>
References: <20070911195239.997111000@menage.corp.google.com>
	<20070911200144.779221000@menage.corp.google.com>
	<20070929214043.57e9cc39.pj@sgi.com>
	<6599ad830709300010xda1e97cp8c569ce08a87a86b@mail.gmail.com>
	<20070930020330.6bd34dd4.akpm@linux-foundation.org>
	<20070930021536.3bd65dc3.pj@sgi.com>
	<20070930022942.b36dd34f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070930022942.b36dd34f.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: dev-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Andrew wrote:
> so when
> their bisection cursor moves within or after the cgroups patches, they'll
> still have CONFIG_CGROUPS=n.  Serendipity.

Unless it's one of the configs that enables cgroups by default, thanks
to the patch:

  task-containers-enable-containers-by-default-in-some-configs.patch

namely configs:

 arch/ia64/configs/sn2_defconfig          |    1 +
 arch/mips/configs/ip27_defconfig         |    1 +
 arch/mips/configs/sb1250-swarm_defconfig |    1 +
 arch/powerpc/configs/cell_defconfig      |    1 +
 arch/powerpc/configs/ppc64_defconfig     |    1 +
 arch/powerpc/configs/pseries_defconfig   |    1 +

But these are not commonly used configs, so that's not a big deal.

So ... yeah ... good enough.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org> 1.925.600.0401
