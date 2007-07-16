From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Containers: css_put() dilemma
Date: Tue, 17 Jul 2007 00:20:40 +0530
Message-ID: <469BBE00.8000709@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759265AbXGPSvN@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Srivatsa Vaddagiri <vatsa@in.ibm.com>, Pavel Emelianov <xemul@sw.ru>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, linux kernel mailing list <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, Paul Jackson <pj@sgi.com>
List-Id: containers.vger.kernel.org

Hi, Paul,

I've run into a strange problem with css_put(). After the changes for notify_on_release(), the css_put() routine can now block and it blocks on
the container_mutex. This implies that css_put() cannot be called if

1. We cannot block
2. We already hold the container_mutex

The problem I have is that of preventing the destruction of my container
(when the user does rmdir). If the user migrates away all tasks and does
an rmdir, the only way to prevent the container from going away is through
css_get() references. In my case, some pages have been allocated from the
container and hence I do not want it to go away, until all the pages
charged to it are freed. When I use css_get/put() to prevent destruction
I am blocked by the limitations of css_put() listed above.

Do you have any recommendations for a cleaner solution? I suspect we'll
need can_destroy() callbacks (similar to can_attach()).

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
